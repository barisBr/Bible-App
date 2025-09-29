import Foundation

public final class WebSocketManager: WebSocketService {
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var continuation: AsyncStream<String>.Continuation?
    private var url: URL?
    
    private var state: WebSocketState = .disconnected
    
    var messages: AsyncStream<String> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
    
    public func connect(to url: URL) {
        self.url = url
        state = .connecting
        
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        state = .connected
        listen()
    }
    
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        state = .disconnected
        continuation?.finish()
    }
    
    public func send(message: String) async throws {
        guard case .connected = state else {
            throw NSError(domain: "WebSocket", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "WebSocket not connected"])
        }
        
        let msg = URLSessionWebSocketTask.Message.string(message)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            webSocketTask?.send(msg) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.state = .failed(error)
                self.continuation?.finish()
                
            case .success(let message):
                switch message {
                case .string(let text):
                    self.continuation?.yield(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.continuation?.yield(text)
                    }
                @unknown default:
                    break
                }
                
                if case .connected = state {
                    self.listen()
                }
            }
        }
    }
}
