import Foundation

public enum NetworkFactory {

    public static func makeAppStatusService(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) -> AppStatusServiceProtocol {
        let client = NetworkClient(
            configuration: configuration,
            session: session
        )

        let objectsRepository = ObjectsRepository(
            client: client,
            configuration: configuration
        )

        let statisticsRepository = StatisticsRepository(
            client: client,
            configuration: configuration
        )

        return AppStatusService(
            objectsRepository: objectsRepository,
            statisticsRepository: statisticsRepository,
            configuration: configuration
        )
    }

    public static func makeAnalyticsRepository(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) -> AnalyticsRepositoryProtocol {
        let client = NetworkClient(
            configuration: configuration,
            session: session
        )

        return AnalyticsRepository(
            client: client,
            configuration: configuration
        )
    }

    public static func makeNetworkClient(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) -> NetworkClientProtocol {
        return NetworkClient(
            configuration: configuration,
            session: session
        )
    }
}
