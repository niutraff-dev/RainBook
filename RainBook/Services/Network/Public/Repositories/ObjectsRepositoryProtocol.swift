import Foundation

public protocol ObjectsRepositoryProtocol: Sendable {
    func fetchWithResult() async -> FetchResult
}
