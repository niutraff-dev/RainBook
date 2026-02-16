import Foundation

public protocol AppStatusServiceProtocol: Sendable {
    func loadStatus() async -> StatusResult
}
