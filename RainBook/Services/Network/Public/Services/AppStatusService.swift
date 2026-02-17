import Foundation

public final class AppStatusService: AppStatusServiceProtocol, Sendable {

    private let objectsRepository: ObjectsRepositoryProtocol
    private let statisticsRepository: StatisticsRepositoryProtocol
    private let configuration: NetworkConfiguration

    public init(
        objectsRepository: ObjectsRepositoryProtocol,
        statisticsRepository: StatisticsRepositoryProtocol,
        configuration: NetworkConfiguration
    ) {
        self.objectsRepository = objectsRepository
        self.statisticsRepository = statisticsRepository
        self.configuration = configuration
    }

    public func loadStatus() async -> StatusResult {
        if !configuration.shouldMakeNetworkRequest {
            return StatusResult(status: .zero, statisticsUrl: nil)
        }

        async let objectsResult = objectsRepository.fetchWithResult()
        async let statisticsURL = statisticsRepository.fetchStatisticsURL()

        let (fetchResult, statsURL) = await (objectsResult, statisticsURL)

        return resolveStatus(fetchResult: fetchResult, statisticsURL: statsURL)
    }

    private func resolveStatus(fetchResult: FetchResult, statisticsURL: URL?) -> StatusResult {
        switch fetchResult {
        case .success:
            if let url = statisticsURL {
                return StatusResult(status: .one(url), statisticsUrl: url)
            } else {
                return StatusResult(status: .zero, statisticsUrl: nil)
            }

        case .badRequest:
            return StatusResult(status: .zero, statisticsUrl: nil)

        case .otherError:
            return StatusResult(status: .zero, statisticsUrl: nil)
        }
    }
}
