//
//  TravelNoteViewModel.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
class TravelNoteViewModel {
    var travelNoteList: [TravelNote]
    
    init() {
        self.travelNoteList = [
            TravelNote(
                title: "First Travel Note",
                city: "New York",
                content: "This is the first travel note",
                date: Date(),
                budget: 3000,
                isFeasible: true,
                expenses: [],
                latitude: 40.7128,
                longitude: -74.0060
            ),
            
            TravelNote(
                title: "Second Travel Note",
                city: "Tokyo",
                content: "This is the second travel note",
                date: Date(),
                budget: 4000,
                isFeasible: true,
                expenses: [],
                latitude: 35.6528,
                longitude: 139.7498
            )
        ]
    }
    
    func addNewTravelNote(travelNote: TravelNote) {
        print("Adding new travel note: \(travelNote)")
        self.travelNoteList.append(travelNote)
        print("New travel note added successfully! \(self.travelNoteList)")
    }
}
