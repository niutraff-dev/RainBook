import Foundation

public protocol StatisticsRepositoryProtocol: Sendable {
    func fetchStatisticsURL() async -> URL?
}
