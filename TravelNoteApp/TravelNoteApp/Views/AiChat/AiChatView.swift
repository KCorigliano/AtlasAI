//
//  AiChatView.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import SwiftUI
import SwiftData

struct AiChatView: View {
    @Environment(\.modelContext) private var modelContext
    
    var service = ViewModelsService()
    @State var viewModel: ChatViewModel
    @State var travelNoteViewModel: TravelNoteViewModel
    @State private var inputText = ""
    @State private var errorSaving: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Gemma trip assistant")
                .font(.headline)
                .padding()
            
            Divider()

            if !viewModel.isModelLoaded {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Assistant configuration")
                        .font(.title2.bold())
                    
                    Text("To start, is needed to download the AI model.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .foregroundColor(.secondary)
                    
                    if viewModel.isDownloading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("loadig...")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.preloadModel()
                            }
                        }) {
                            Text("Download AI model")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 50)
                    }
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
                
                if viewModel.isGenerating && (viewModel.messages.last?.isUser == true) {
                    HStack {
                        ProgressView()
                            .padding(.horizontal)
                        Text("Gemma is analazing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                if errorSaving {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text("Itinerary not feasible.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                if viewModel.containJson && ((viewModel.lastAiResponse?.feasibility) == true) {
                    Button(action: saveTripToNotes) {
                        Label("Save itinerary to Notes", systemImage: "folder.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Divider()
                
                HStack(alignment: .bottom) {
                    TextField("Ask an itinerary...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .disabled(viewModel.isGenerating)
                    
                    Button(action: sendMessage) {
                        Image(systemName: viewModel.isGenerating ? "stop.circle.fill" : "paperplane.fill")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.isGenerating ? .red : .blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isGenerating)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText
        inputText = ""
        Task {
            await viewModel.sendMessage(text)
        }
    }

    private func saveTripToNotes() {
        if let lastMessageText = viewModel.messages.last?.text,
           let aiResponse = service.extractAndParseJson(text: lastMessageText) {
            
            if aiResponse.feasibility == false {
                errorSaving = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.errorSaving = false
                }
                return
            }

            let newNote = service.convertToTravelNote(from: aiResponse)
            modelContext.insert(newNote)
            viewModel.containJson = false
        }
    }
}

#Preview("Status: before model download") {
    let chatViewModel = ChatViewModel(previewState: .needsDownload)
    let travelNoteViewModel = TravelNoteViewModel()
    AiChatView(viewModel: chatViewModel, travelNoteViewModel: travelNoteViewModel)
}

#Preview("Status: after model download") {
    let chatViewModel = ChatViewModel(previewState: .fullyLoaded)
    let travelNoteViewModel = TravelNoteViewModel()
    AiChatView(viewModel: chatViewModel, travelNoteViewModel: travelNoteViewModel)
}
