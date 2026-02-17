import Foundation

public protocol AnalyticsRepositoryProtocol: Sendable {
    func sendEvent() async -> Bool
}
