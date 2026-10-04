//
//  ChatBubble.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 22/04/2026.
//

import SwiftUI

import SwiftUI

struct AiMessageContent: Codable {
    let opinion_assessment: String?
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var displayText: String {
        if message.isUser { return message.text }
        
        return parseDisplayableText(from: message.text)
    }
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(displayText)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .fixedSize(horizontal: false, vertical: true)
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 4)
    }
    
    private func parseDisplayableText(from text: String) -> String {
        guard let firstBrace = text.firstIndex(of: "{"),
              let lastBrace = text.lastIndex(of: "}"),
              firstBrace < lastBrace else {
            return text
        }
        
        let jsonString = String(text[firstBrace...lastBrace])
        guard let data = jsonString.data(using: .utf8) else { return text }
        
        if let decoded = try? JSONDecoder().decode(AiMessageContent.self, from: data),
           let assessment = decoded.opinion_assessment {
            return assessment
        }
        
        return text
    }
}
#Preview {
    let message = ChatMessage(
        id: UUID(),
        text: "Hi! I'm your assistant. How can I help you today?",
        isUser: false
    )

    return ChatBubble(message: message)
        .padding() 
}
