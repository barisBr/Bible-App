//
//  ChatSessionEntity.swift
//  Bibble
//
//  Created by Emre Bingör on 25.09.2025.
//

import Foundation

struct SessionEntity: Identifiable, Equatable {
    let id: UUID
    let createdTime: Date
    let messages: [MessageEntity]

    init(
        id: UUID = UUID(),
        createdTime: Date = Date(),
        messages: [MessageEntity] = []
    ) {
        self.id = id
        self.createdTime = createdTime
        self.messages = messages
    }
}
