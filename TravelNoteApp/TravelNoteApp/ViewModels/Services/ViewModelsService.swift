//
//  ViewModelsService.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 28/04/2026.
//

import Foundation
import NaturalLanguage
import MapKit

struct AiItineraryItem: Codable {
    let day: Int
    let activity: String
    let estimated_price: Double
    let category: String
}

struct AiTripResponse: Codable {
    let opinion_assessment: String
    let feasibility: Bool
    let currency_exchange_evaluation: String
    let destination_city: String
    let duration: Int
    let calculated_daily_allowance: Double
    let budget_breakdown: String
    let total_budget: Double
    let latitude: Double?
    let longitude: Double?
    let itinerary: [AiItineraryItem]
}

struct FrankfurterResponse: Codable { let rate: Double }
struct WhereNextCostResponse: Codable { let data: WhereNextCostData?; let summary: String? }
struct WhereNextCostData: Codable { let monthly_usd: [String: Double]? }

struct MapKitResult { let currencyCode: String; let countryCode: String }

class ViewModelsService {
    
    func extractCity(from text: String) -> String? {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        var city: String?
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: [.joinNames]) { tag, range in
            if tag == .placeName { city = String(text[range]); return false }
            return true
        }
        return city
    }
    
    func getGeoData(for city: String) async -> MapKitResult? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city
        
        guard let item = try? await MKLocalSearch(request: request).start().mapItems.first else { return nil }
        
        let countryCode = item.placemark.countryCode ?? ""
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode]))
        let currency = locale.currency?.identifier ?? "USD"
        
        return MapKitResult(currencyCode: currency, countryCode: countryCode)
    }

    func fetchExchangeRate(from base: String, to target: String) async -> Double {
        if base == target { return 1.0 }
        let url = URL(string: "https://api.frankfurter.dev/v2/rate/\(base)/\(target)")!
        let data = try? await URLSession.shared.data(from: url).0
        return (try? JSONDecoder().decode(FrankfurterResponse.self, from: data ?? Data()))?.rate ?? 1.0
    }

    func fetchCityCosts(countryCode: String?) async -> String {
        guard let code = countryCode?.lowercased(),
              let url = URL(string: "https://getwherenext.com/api/data/ai-cost-of-living/\(code)"),
              let (data, _) = try? await URLSession.shared.data(from: url) else { return "Data not available" }
        
        let decoded = try? JSONDecoder().decode(WhereNextCostResponse.self, from: data)
        return decoded?.summary ?? "Average cost of living is not available"
    }

    func getSystemPrompt(text: String) async -> String {
        let city = extractCity(from: text) ?? "Unknown"
        let geo = await getGeoData(for: city)
        let userCurrency = Locale.current.currency?.identifier ?? "EUR"
        let targetCurrency = geo?.currencyCode ?? "EUR"
        
        let rate = await fetchExchangeRate(from: userCurrency, to: targetCurrency)
        let costs = await fetchCityCosts(countryCode: geo?.countryCode)
        
        return """
        Role: Expert Travel Analyst. Response Language: Match user.
        
        [REAL-TIME DATA FOR \(city.uppercased())]
        - Base Currency: \(userCurrency)
        - Destination Currency: \(targetCurrency)
        - Exchange Rate: 1 \(userCurrency) = \(rate) \(targetCurrency)
        - Local Cost Reference: \(costs)
        
        PHASE 1: FINANCIAL CALCULATION (INTERNAL)
        1. Convert the user's total budget to \(targetCurrency) using the rate \(rate).
        2. Divide by the number of days to get the "calculated_daily_allowance" in \(targetCurrency).
        3. Compare this allowance with the "Local Cost Reference".
        
        PHASE 2: FEASIBILITY & OPINION
        - If the daily allowance is lower than the local cost for a basic bed and meal: feasibility = false.
        - In "opinion_assessment", you MUST mention if the exchange rate is favorable and how the local cost of living impacts their budget.
        - In "currency_exchange_evaluation", summarize: "\(userCurrency) to \(targetCurrency) conversion is [favorable/unfavorable]".
        
        PHASE 3: OUTPUT
        - If feasibility is true: Output ONLY the JSON.
        - If feasibility is false: Output ONLY a short, ironic, and witty explanation (roast) of why the budget is a fantasy.
        
        JSON Structure:
        {
          "opinion_assessment": "Detailed analysis including exchange rate impact and local cost context",
          "feasibility": boolean,
          "currency_exchange_evaluation": "Summary of the conversion and rate",
          "destination_city": "\(city)",
          "duration": "number of days",
          "calculated_daily_allowance": double (IN LOCAL CURRENCY),
          "budget_breakdown": "How the daily allowance covers food, transport, and sleep",
          "total_budget": double (Original user budget),
          "latitude": double,
          "longitude": double,
          "itinerary": [{ "day": int, "activity": "string", "estimated_price": double (IN LOCAL CURRENCY), "category": "string" }]
        }
        """
    }

    func convertToTravelNote(from aiResponse: AiTripResponse) -> TravelNote {
        let itinerarySummary = aiResponse.itinerary
            .map { "- Day \($0.day): \($0.activity) (\($0.estimated_price))" }
            .joined(separator: "\n")
        
        let content = """
        Destination: \(aiResponse.destination_city)
        Daily allowance: \(aiResponse.calculated_daily_allowance)
        
        Itinerary:
        \(itinerarySummary)
        """
        
        return TravelNote(
            title: "Trip to \(aiResponse.destination_city)",
            city: aiResponse.destination_city,
            content: content,
            date: Date(),
            budget: aiResponse.total_budget,
            isFeasible: aiResponse.feasibility,
            expenses: [],
            latitude: aiResponse.latitude ?? 0.00,
            longitude: aiResponse.longitude ?? 0.00
        )
    }
    
    func extractAndParseJson(text: String) -> AiTripResponse? {
        guard let firstBrace = text.firstIndex(of: "{"),
              let lastBrace = text.lastIndex(of: "}") else { return nil }
        
        let jsonString = String(text[firstBrace...lastBrace])
        let data = jsonString.data(using: .utf8)!
        
        do {
            return try JSONDecoder().decode(AiTripResponse.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
    
    func stringContainJson(text: String) -> Bool {
        return text.contains("{") && text.contains("}")
    }
}

