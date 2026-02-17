import Foundation

public protocol NetworkClientProtocol: Sendable {
    func request(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Data?

    func requestWithResult(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Result<Data, NetworkError>
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
