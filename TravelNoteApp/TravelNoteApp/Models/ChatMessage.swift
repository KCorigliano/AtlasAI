//
//  ChatMessage.swift
//  TravelNoteApp
//
//  Created by Kevin Corigliano on 20/04/26.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
