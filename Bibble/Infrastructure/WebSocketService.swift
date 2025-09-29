//
//  WebSocketService.swift
//  Bibble
//
//  Created by Emre Bingör on 29.09.2025.
//

import Foundation


enum WebSocketState {
    case connected
    case disconnected
    case connecting
    case failed(Error)
}

protocol WebSocketService {
    func connect(to url: URL)
    func disconnect()
    func send(message: String) async throws
    
    var messages: AsyncStream<String> { get }
}
