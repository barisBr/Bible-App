//
//  ChatUseCase.swift
//  Bibble
//
//  Created by Emre Bingör on 25.09.2025.
//

import Foundation

protocol MessageUseCase {
    func sendMessage(content: String, in session: SessionEntity) async throws
    func observeMessages(session: SessionEntity) -> AsyncStream<MessageEntity>
}
