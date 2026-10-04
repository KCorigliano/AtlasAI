//
//  TravelNoteCreateView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI
import MapKit
import SwiftData

struct TravelNoteCreateView: View {
    @State var viewModel: TravelNoteViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var city = ""
    @State private var content = ""
    @State private var budget = 0.00
    @State private var isLocating = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General information")) {
                    TextField("Trip title", text: $title)
                    TextField("city", text: $city)
                }
                
                Section(header: Text("Budget")) {
                    TextField("Budget", value: $budget, formatter: CurrencyFormatter())
                }
                
                Section(header: Text("Trip details")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: {
                        Task { await geocodeAndSave() }
                    }) {
                        HStack {
                            if isLocating {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("Create Nota")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(title.isEmpty || city.isEmpty || isLocating)
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func geocodeAndSave() async {
        isLocating = true
        defer { isLocating = false }
        guard let request = MKGeocodingRequest(addressString: city) else {
            print("Errore: inalid request")
            return
        }
        do {
            let mapItems = try await request.mapItems
            if let location = mapItems.first?.location {
                let newNote = TravelNote(
                    title: title,
                    city: city,
                    content: content,
                    date: Date(),
                    budget: budget,
                    isFeasible: true,
                    expenses: [],
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                modelContext.insert(newNote)
                dismiss()
            } else {
                print("Errore: city not found")
            }
        } catch {
            print("Error geocoding: \(error.localizedDescription)")
        }
    }
}

final class CurrencyFormatter: NumberFormatter, @unchecked Sendable {
    override init() {
        super.init()
        self.numberStyle = .currency
        self.locale = Locale.current
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    var viewModel = TravelNoteViewModel()
    TravelNoteCreateView(viewModel: viewModel)
}
