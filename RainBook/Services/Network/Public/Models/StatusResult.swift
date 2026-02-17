import Foundation

public struct StatusResult: Sendable, Equatable {
    public let status: AppStatus
    public let statisticsUrl: URL?

    public init(status: AppStatus, statisticsUrl: URL? = nil) {
        self.status = status
        self.statisticsUrl = statisticsUrl
    }
}
