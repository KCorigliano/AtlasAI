//
//  ChatViewModel.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//
//  To test AI: select device My mac or a physical device iPhone pro 15 +,
//  won't work on simulator or weaker devices
//  Documentation: https://swiftpackageindex.com/ml-explore/mlx-swift-lm/main/documentation/mlxlmcommon/using


// CoreML (?)

import Foundation
import MLXLLM
import MLXLMCommon
import MLXHuggingFace
import NaturalLanguage

import HuggingFace
import Tokenizers
import Observation

@Observable
@MainActor
class ChatViewModel {
    
    var messages: [ChatMessage] = []
    var isGenerating: Bool = false
    var containJson: Bool = false
    var lastAiResponse: AiTripResponse?
    
    var isDownloading: Bool = false
    var isModelLoaded: Bool = false
    var downloadProgress: Double = 0.0
    
    var service = ViewModelsService()
    
    private var session: ChatSession?
    
    enum PreviewState {
        case none
        case needsDownload
        case fullyLoaded
    }
    
    init(previewState: PreviewState = .none) {
        switch previewState {
        case .needsDownload:
            self.isModelLoaded = false
            self.isDownloading = false
            self.downloadProgress = 0.0
        case .fullyLoaded:
            self.isModelLoaded = true
            self.isDownloading = false
            self.messages = [ChatMessage(text: "Preview: Modell loaded!", isUser: false)]
        case .none:
            break
        }
    }

    func preloadModel() async {
        guard !isModelLoaded else { return }
        isDownloading = true
        
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondi
                self.downloadProgress = Double(i) / 10.0
            }
            self.isModelLoaded = true
            self.isDownloading = false
            return
        }
        #endif
        
        self.session = nil
        
        do {
            let modelConfiguration = LLMRegistry.gemma4_e2b_it_4bit
            
            let model = try await #huggingFaceLoadModelContainer(configuration: modelConfiguration)
            self.session = ChatSession(model)
            
            self.isModelLoaded = true
        } catch {
            print(error)
        }
        isDownloading = false
    }
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, isUser: true)
        self.messages.append(userMessage)
        
        self.isGenerating = true
        
        do {
            guard isModelLoaded, let currentSession = session else {
                let errorMsg = ChatMessage(text: "Errore: load the model before chatting.", isUser: false)
                self.messages.append(errorMsg)
                return
            }
            
            let fullPrompt = """
                        <|im_start|>system
                        \(await service.getSystemPrompt(text: text))
                        <|im_end|>
                        <|im_start|>user
                        \(text)
                        <|im_end|>
                        <|im_start|>assistant
                        """
            
            let responseText = try await currentSession.respond(to: fullPrompt)
            
            let aiMessage = ChatMessage(text: responseText, isUser: false)
            
            print("containjson: \(service.stringContainJson(text: aiMessage.text))")
            
            if service.stringContainJson(text: aiMessage.text) {
                self.containJson = true
                lastAiResponse = service.extractAndParseJson(text: aiMessage.text)
                print("lastAiResponse: \(lastAiResponse)")
            }
            
            self.messages.append(aiMessage)
            
        } catch {
            print("CRITICAL ERROR: \(error)")
            dump(error)
            
            let errorMessage = ChatMessage(text: "Error", isUser: false)
            self.messages.append(errorMessage)
        }
        
        self.isGenerating = false
    }
}

