//
//  WebSocketService.swift
//  Bibble
//
//  Created by Emre Bingör on 29.09.2025.
//

import Foundation


public enum WebSocketError: Error {
    case sendFailed
    case receiveFailed
    case disconnected
    case unknown(String)
}

public enum WebSocketState {
    case connected
    case disconnected
    case connecting
    case failed(WebSocketError)
}

protocol WebSocketService {
    func connect(to url: URL)
    func disconnect()
    func send(message: String) async throws
    
    var messages: AsyncStream<String> { get }
}
