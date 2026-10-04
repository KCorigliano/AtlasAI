//
//  TravelNote.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Expense {
    @Attribute(.unique) var id: UUID = UUID()

    var name: String
    var amount: Double

    init(id: UUID = UUID(), name: String, amount: Double) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

@Model
final class TravelNote {
    @Attribute(.unique) var id: UUID = UUID()
    
    var title: String
    var city: String
    var content: String
    var date: Date
    var budget: Double
    var isFeasible: Bool
    var expenses: [Expense] = []

    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(title: String, city: String, content: String, date: Date, budget: Double, isFeasible: Bool, expenses: [Expense] = [], latitude: Double, longitude: Double) {
        self.id = UUID()
        self.title = title
        self.city = city
        self.content = content
        self.date = date
        self.budget = budget
        self.isFeasible = isFeasible
        self.expenses = expenses
        self.latitude = latitude
        self.longitude = longitude
    }
}
