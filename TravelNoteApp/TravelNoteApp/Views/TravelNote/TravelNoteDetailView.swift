//
//  TravelNoteDetailView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI
import SwiftData
import MapKit

struct TravelNoteDetailView: View {
    @Bindable var note: TravelNote
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showExpense: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("General information")) {
                TextField("Travel title", text: $note.title)
                    .font(.headline)
                
                Text(note.city)
                
                DatePicker("Date", selection: $note.date, displayedComponents: .date)
            }
            
            Section {
                HStack {
                    Image(systemName: "eurosign.circle")
                        .foregroundColor(.green)
                    Text("Budget")
                    Spacer()
                    TextField("Budget", value: $note.budget, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "eurosign.circle")
                        .foregroundColor(.red)
                    Text("Final expenses")
                    Spacer()
                    if note.expenses.isEmpty {
                        Text(0 as Decimal, format: .currency(code: "EUR"))
                            .foregroundColor(.secondary)
                    } else {
                        Text(Decimal(fetchTotalCost()) as Decimal, format: .currency(code: "EUR"))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Travel notes")) {
                TextEditor(text: $note.content)
                    .frame(minHeight: 150)
            }
            
            Section(header:
                HStack {
                    Text("Expenses")
                    Spacer()
                Button (action: {showExpense.toggle()}){
                        Text("Add expense")
                            .font(Font.body.monospacedDigit())
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                                    .padding(4)
                                )
                    }
                }
            ) {
                if note.expenses.isEmpty {
                    Text("No expenses yet").foregroundColor(.secondary)
                }
                ForEach(note.expenses) { expense in
                    HStack {
                        Text(expense.name)
                        Spacer()
                        Text(expense.amount, format: .currency(code: "EUR"))
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { indexSet in
                    note.expenses.remove(atOffsets: indexSet)
                }
            }
            
            Section(header: Text("Position")) {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: note.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))) {
                    Marker(note.city, coordinate: note.coordinate)
                }
                .frame(height: 200)
                .cornerRadius(12)
                .listRowInsets(EdgeInsets())
            }
        }
        .sheet (isPresented: $showExpense) {
            ExpenseCreateView(travelNote: note)
        }
        .navigationTitle("Travel Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveAndExit()
                }
            }
        }
    }
    
    private func saveAndExit() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchTotalCost() -> Double {
        note.expenses.reduce(0) { $0 + $1.amount }
    }
}

#Preview {
    var note = TravelNote(
        title: "First Travel Note",
        city: "New York",
        content: "This is the first travel note",
        date: Date(),
        budget: 3000,
        isFeasible: true,
        expenses:  [],
        latitude: 40.7128,
        longitude: -74.0060
    )
    
    TravelNoteDetailView(note: note)
}

