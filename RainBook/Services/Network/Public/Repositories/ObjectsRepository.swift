import Foundation

public final class ObjectsRepository: ObjectsRepositoryProtocol, Sendable {

    private let client: NetworkClientProtocol
    private let configuration: NetworkConfiguration

    public init(client: NetworkClientProtocol, configuration: NetworkConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    public func fetchWithResult() async -> FetchResult {
        let queryItems = [URLQueryItem(name: "version", value: configuration.effectiveAPIVersion)]

        let result = await client.requestWithResult(
            path: configuration.endpointPaths.objects,
            method: .get,
            queryItems: queryItems,
            requiresAuth: true
        )

        switch result {
        case .success:
            return .success

        case .failure(.badRequest):
            return .badRequest

        case .failure:
            return .otherError
        }
    }
}
