import Foundation

public struct NetworkConfiguration: Sendable {
    public let baseURL: URL
    public let userAgent: String?
    public let basicAuth: (username: String, password: String)?
    public let mode: NetworkMode
    public let appVersion: String
    public let endpointPaths: EndpointPaths

    public init(
        baseURL: URL,
        userAgent: String? = nil,
        basicAuth: (username: String, password: String)? = nil,
        mode: NetworkMode = .default,
        appVersion: String = "1",
        endpointPaths: EndpointPaths = EndpointPaths()
    ) {
        self.baseURL = baseURL
        self.userAgent = userAgent
        self.basicAuth = basicAuth
        self.mode = mode
        self.appVersion = appVersion
        self.endpointPaths = endpointPaths
    }
}

extension NetworkConfiguration {
    var shouldMakeNetworkRequest: Bool {
        if mode == .default && appVersion == "1" {
            return false
        }
        return true
    }

    var effectiveAPIVersion: String {
        return "2"
    }
}
