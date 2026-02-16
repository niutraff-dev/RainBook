import Foundation
@testable import Network

final class MockStatisticsRepository: StatisticsRepositoryProtocol, @unchecked Sendable {

    var fetchCount = 0

    var result: URL?

    func fetchStatisticsURL() async -> URL? {
        fetchCount += 1
        return result
    }

    func stubURL(_ url: URL) {
        result = url
    }

    func stubFailure() {
        result = nil
    }
}
