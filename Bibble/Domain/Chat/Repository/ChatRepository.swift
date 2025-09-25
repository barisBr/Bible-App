//
//  ChatRepository.swift
//  Bibble
//
//  Created by Emre Bingör on 25.09.2025.
//

import Foundation

protocol ChatRepository {
    func sendMessage(_ content: String, in session: SessionEntity) async throws 
    func observeMessages(in session: SessionEntity) -> AsyncStream<MessageEntity>
}
