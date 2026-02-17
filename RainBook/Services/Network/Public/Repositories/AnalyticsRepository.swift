import Foundation

public final class AnalyticsRepository: AnalyticsRepositoryProtocol, Sendable {

    private let client: NetworkClientProtocol
    private let configuration: NetworkConfiguration

    public init(client: NetworkClientProtocol, configuration: NetworkConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    public func sendEvent() async -> Bool {
        let data = await client.request(
            path: configuration.endpointPaths.analytics,
            method: .post,
            queryItems: nil,
            requiresAuth: true
        )

        return data != nil
    }
}
