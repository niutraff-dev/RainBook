import Foundation

public final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {

    private let configuration: NetworkConfiguration
    private let session: URLSession
    private let logger: NetworkLoggerProtocol

    public init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared,
        logger: NetworkLoggerProtocol = DefaultNetworkLogger()
    ) {
        self.configuration = configuration
        self.session = session
        self.logger = logger
    }

    public func request(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Data? {
        let result = await requestWithResult(
            path: path,
            method: method,
            queryItems: queryItems,
            requiresAuth: requiresAuth
        )

        switch result {
        case .success(let data):
            return data
        case .failure:
            return nil
        }
    }

    public func requestWithResult(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Result<Data, NetworkError> {
        guard let url = buildURL(path: path, queryItems: queryItems) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        applyHeaders(to: &request, requiresAuth: requiresAuth, method: method)

        logger.logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.logError(url: url, error: NetworkError.invalidResponse)
                return .failure(.invalidResponse)
            }

            logger.logResponse(url: url, statusCode: httpResponse.statusCode, data: data)

            if let error = NetworkError.from(statusCode: httpResponse.statusCode) {
                return .failure(error)
            }

            return .success(data)
        } catch let error as URLError where error.code == .timedOut {
            logger.logError(url: url, error: NetworkError.timeout)
            return .failure(.timeout)
        } catch {
            logger.logError(url: url, error: error)
            return .failure(.networkFailure)
        }
    }

    private func buildURL(path: String, queryItems: [URLQueryItem]?) -> URL? {
        var components = URLComponents()
        components.scheme = configuration.baseURL.scheme
        components.host = configuration.baseURL.host
        components.path = "/" + path
        components.queryItems = queryItems

        return components.url
    }

    private func applyHeaders(to request: inout URLRequest, requiresAuth: Bool, method: HTTPMethod) {
        if let userAgent = configuration.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        if requiresAuth, let auth = configuration.basicAuth {
            let credentials = "\(auth.username):\(auth.password)"
            if let data = credentials.data(using: .utf8) {
                let encoded = data.base64EncodedString()
                request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
            }
        }

        if method == .post {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
