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
        
    func connect(to url: URL) {
        self.url = url
        state = .connecting
        print("WebSocket connecting to \(url)")

        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        state = .connected
        print("WebSocket connected to \(url)")

        listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        state = .disconnected
        continuation?.finish()
        print("WebSocket disconnected")
    }
    
    func send(message: String) async throws {
        guard case .connected = state else {
            throw WebSocketError.disconnected
        }
        
        let msg = URLSessionWebSocketTask.Message.string(message)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            webSocketTask?.send(msg) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                    continuation.resume(throwing: WebSocketError.sendFailed)
                } else {
                    print("WebSocket sent message: \(message)")
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
                self.state = .failed(.receiveFailed)
                self.continuation?.finish()
                print("WebSocket receive error: \(error)")

            case .success(let message):
                switch message {
                case .string(let text):
                    self.continuation?.yield(text)
                    print("WebSocket received string: \(text)")
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.continuation?.yield(text)
                        print("WebSocket received data as string: \(text)")
                    }
                @unknown default:
                    self.state = .failed(.unknown("Unknown message type"))
                    self.continuation?.finish()
                    print("WebSocket received unknown message type")
                    break
                }
                
                if case .connected = state {
                    self.listen()
                }
            }
        }
    }
}
