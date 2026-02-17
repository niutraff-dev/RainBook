import Foundation

public final class StatisticsRepository: StatisticsRepositoryProtocol, Sendable {

    private let client: NetworkClientProtocol
    private let configuration: NetworkConfiguration

    public init(client: NetworkClientProtocol, configuration: NetworkConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    public func fetchStatisticsURL() async -> URL? {
        let queryItems = [URLQueryItem(name: "version", value: configuration.effectiveAPIVersion)]

        let data = await client.request(
            path: configuration.endpointPaths.statistics,
            method: .get,
            queryItems: queryItems,
            requiresAuth: false
        )

        guard let data = data else {
            return nil
        }

        return Base64Decoder.decodeURL(from: data)
    }
}
