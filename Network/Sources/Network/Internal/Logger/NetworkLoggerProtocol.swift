import Foundation

public protocol NetworkLoggerProtocol: Sendable {
    func logRequest(_ request: URLRequest)
    func logResponse(url: URL, statusCode: Int, data: Data?)
    func logError(url: URL, error: Error)
}
