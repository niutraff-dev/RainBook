import Foundation
@testable import Network

final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {

    var requestCount = 0

    var lastRequestedPath: String?

    var lastQueryItems: [URLQueryItem]?

    var objectsResult: Result<Data, NetworkError> = .failure(.networkFailure)

    var statisticsResult: Data?

    var analyticsResult: Data?

    func request(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Data? {
        requestCount += 1
        lastRequestedPath = path
        lastQueryItems = queryItems

        if path.contains("Statistic") || path.contains("statistic") || path.contains("Stats") || path.contains("stats") {
            return statisticsResult
        } else if path.contains("analytic") || path.contains("add") || path.contains("track") {
            return analyticsResult
        }

        // Default for objects
        if case .success(let data) = objectsResult {
            return data
        }
        return nil
    }

    func requestWithResult(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        requiresAuth: Bool
    ) async -> Result<Data, NetworkError> {
        requestCount += 1
        lastRequestedPath = path
        lastQueryItems = queryItems

        return objectsResult
    }

    func reset() {
        requestCount = 0
        lastRequestedPath = nil
        lastQueryItems = nil
        objectsResult = .failure(.networkFailure)
        statisticsResult = nil
        analyticsResult = nil
    }

    func stubObjectsSuccess() {
        objectsResult = .success(Data())
    }

    func stubObjectsBadRequest() {
        objectsResult = .failure(.badRequest)
    }

    func stubObjectsError(_ error: NetworkError = .networkFailure) {
        objectsResult = .failure(error)
    }

    func stubStatisticsURL(_ url: URL) {
        let urlString = url.absoluteString
        statisticsResult = Data(urlString.utf8).base64EncodedData()
    }

    func stubStatisticsFailure() {
        statisticsResult = nil
    }

    func stubStatisticsInvalidBase64() {
        statisticsResult = "invalid-base64-!!!".data(using: .utf8)
    }
}
