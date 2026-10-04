//
//  ExpenseCreateView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 06/05/2026.
//

import SwiftUI
import SwiftData

struct ExpenseCreateView: View {
    @State var travelNote: TravelNote
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var cost: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Expenses information")) {
                    TextField("Expense title", text: $title)
                    TextField("Cost", text: $cost)
                }
                
                Button("Create") {
                    createExpense()
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(cost) == nil)
            }
        }
    }
    
    private func createExpense() {
        let expense = Expense(name: title, amount: Double(cost) ?? 0)
        
        travelNote.expenses.append(expense)
        modelContext.insert(travelNote)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    let travelNote = TravelNote(title: "Test", city: "Test", content: "Test", date: Date(), budget: 0, isFeasible: true, expenses: [], latitude: 0, longitude: 0)
    ExpenseCreateView(travelNote: travelNote)
}
