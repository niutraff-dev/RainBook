import Foundation

public enum NetworkError: Error, Sendable, Equatable {
    case badRequest
    case unauthorized
    case notFound
    case serverError(Int)
    case httpError(Int)
    case networkFailure
    case invalidURL
    case invalidResponse
    case timeout
}

extension NetworkError {
    static func from(statusCode: Int) -> NetworkError? {
        switch statusCode {
        case 200..<300:
            return nil
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 500..<600:
            return .serverError(statusCode)
        default:
            return .httpError(statusCode)
        }
    }
}
