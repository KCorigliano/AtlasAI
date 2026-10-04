//
//  NavigatorView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI

struct NavigatorView: View {
    
    @State private var travelNoteViewModel = TravelNoteViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView (selection: $selectedTab) {
            TravelNotesListView(travelNoteViewModel: travelNoteViewModel)
                .tabItem {
                    Label("plane", systemImage: "airplane")
                }
                .tag(0)
            
            // Gemma 4 available only on top models (crash on weaker devices)
            // Maybe a second tab just for weaker devices with gemma 3 and different tasks
            // ToDo: Search if is possible to recognize devices
            AiChatView(viewModel: chatViewModel, travelNoteViewModel: travelNoteViewModel)
                .tabItem {
                    Label("chat", systemImage: "bubble.right")
                }
                .tag(1)
            
            TravelMap()
                .tabItem {
                    Label("map", systemImage: "map")
                }
                .tag(2)
            
            // Apple inteligence not really a good alternative, is really bad
            //AppleAiChatView()
            //    .tabItem {
            //        Label("chat Apple", systemImage: "applelogo")
            //    }
            //    .tag(3)
        }
        .environment(travelNoteViewModel)
        .environment(chatViewModel)
    }
}

#Preview {
    NavigatorView()
}
