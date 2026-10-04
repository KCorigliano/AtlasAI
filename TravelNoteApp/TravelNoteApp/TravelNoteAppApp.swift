//
//  TravelNoteAppApp.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI
import SwiftData

@main
struct TravelNoteAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigatorView()
        }
        .modelContainer(for: TravelNote.self)
    }
}
