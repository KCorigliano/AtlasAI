//
//  TravelMap.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 23/04/2026.
//

import SwiftUI
import MapKit
import SwiftData

struct TravelMap: View {
    @Query(sort: \TravelNote.date, order: .forward) var travelNotes: [TravelNote]
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var selectedNote: TravelNote?

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedNote) {
            ForEach(travelNotes) { note in
                Marker(note.title, coordinate: note.coordinate)
                    .tint(.blue)
                    .tag(note)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .sheet(item: $selectedNote) { note in
            VStack(alignment: .leading, spacing: 20) {
                Text(note.title).font(.title).bold()
                Text(note.city).font(.headline).foregroundColor(.secondary)
                Divider()
                Text(note.content)
                Spacer()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}
#Preview {
    TravelMap()
}
