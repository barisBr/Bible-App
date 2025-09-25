//
//  ChatMessageEntity.swift
//  Bibble
//
//  Created by Emre Bingör on 25.09.2025.
//

import Foundation

enum UserType {
    case ai
    case user
}

struct MessageEntity: Identifiable, Equatable {
    
    let id: UUID
    let message: String
    let role: UserType
    let time: Date
    
    init(
        id: UUID = UUID(),
        role: UserType,
        message: String,
        time: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.message = message
        self.time = time
    }
}
