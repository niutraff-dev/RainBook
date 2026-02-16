import Foundation
@testable import Network

final class MockObjectsRepository: ObjectsRepositoryProtocol, @unchecked Sendable {

    var fetchCount = 0

    var result: FetchResult = .otherError

    func fetchWithResult() async -> FetchResult {
        fetchCount += 1
        return result
    }

    func stubSuccess() {
        result = .success
    }

    func stubBadRequest() {
        result = .badRequest
    }

    func stubError() {
        result = .otherError
    }
}
