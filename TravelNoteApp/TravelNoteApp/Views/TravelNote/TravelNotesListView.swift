//
//  ContentView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI
import SwiftData

struct TravelNotesListView: View {
    @Query(sort: \TravelNote.date, order: .forward) var travelNoteList: [TravelNote]
    @Environment(\.modelContext) private var modelContext
    let travelNoteViewModel: TravelNoteViewModel
    @State var showCreateNoteModal: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(travelNoteList) { note in
                    NavigationLink(destination: TravelNoteDetailView(note: note)) {
                        Text(note.title)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(note)
                            try? modelContext.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Travels")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateNoteModal.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showCreateNoteModal) {
                TravelNoteCreateView(viewModel: travelNoteViewModel)
            }
        }
        .onAppear() {
            print("travelNotList: \(travelNoteList)")
        }
    }
}

#Preview {
    let travelNoteViewModel = TravelNoteViewModel()
    TravelNotesListView(travelNoteViewModel: travelNoteViewModel)
}
