import Foundation

public final class DefaultNetworkLogger: NetworkLoggerProtocol, Sendable {

    public init() {}

    public func logRequest(_ request: URLRequest) {
        guard let url = request.url else { return }

        let method = request.httpMethod ?? "GET"

        var curlCommand = "curl --request \(method) --url '\(url.absoluteString)'"

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers where key != "Authorization" {
                curlCommand += " --header '\(key): \(value)'"
            }
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            curlCommand += " --data '\(bodyString)'"
        }
    }

    public func logResponse(url: URL, statusCode: Int, data: Data?) {
        let emoji = (200..<300).contains(statusCode) ? "✅" : "❌"

        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
            } else if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            }
        }
    }

    public func logError(url: URL, error: Error) {}
}
