import XCTest
@testable import Network

final class NetworkConfigurationTests: XCTestCase {

    private let testURL = URL(string: "https://api.test.com")!

    func test_default_v1_shouldNotMakeRequest() {
        let config = NetworkConfiguration(
            baseURL: testURL,
            mode: .default,
            appVersion: "1"
        )

        XCTAssertFalse(config.shouldMakeNetworkRequest)
    }

    func test_default_v2_shouldMakeRequest() {
        let config = NetworkConfiguration(
            baseURL: testURL,
            mode: .default,
            appVersion: "2"
        )

        XCTAssertTrue(config.shouldMakeNetworkRequest)
    }

    func test_default_v3_shouldMakeRequest() {
        let config = NetworkConfiguration(
            baseURL: testURL,
            mode: .default,
            appVersion: "3"
        )

        XCTAssertTrue(config.shouldMakeNetworkRequest)
    }

    func test_combat_v1_shouldMakeRequest() {
        let config = NetworkConfiguration(
            baseURL: testURL,
            mode: .combat,
            appVersion: "1"
        )

        XCTAssertTrue(config.shouldMakeNetworkRequest)
    }

    func test_combat_v2_shouldMakeRequest() {
        let config = NetworkConfiguration(
            baseURL: testURL,
            mode: .combat,
            appVersion: "2"
        )

        XCTAssertTrue(config.shouldMakeNetworkRequest)
    }

    func test_effectiveAPIVersion_alwaysReturns2() {
        let configs = [
            NetworkConfiguration(baseURL: testURL, mode: .default, appVersion: "1"),
            NetworkConfiguration(baseURL: testURL, mode: .default, appVersion: "2"),
            NetworkConfiguration(baseURL: testURL, mode: .default, appVersion: "3"),
            NetworkConfiguration(baseURL: testURL, mode: .combat, appVersion: "1"),
            NetworkConfiguration(baseURL: testURL, mode: .combat, appVersion: "99"),
        ]

        for config in configs {
            XCTAssertEqual(config.effectiveAPIVersion, "2")
        }
    }

    func test_defaultEndpointPaths() {
        let config = NetworkConfiguration(baseURL: testURL)

        XCTAssertEqual(config.endpointPaths.objects, "getFiles")
        XCTAssertEqual(config.endpointPaths.statistics, "getDetails")
        XCTAssertEqual(config.endpointPaths.analytics, "addFeedback")
    }

    func test_defaultMode() {
        let config = NetworkConfiguration(baseURL: testURL)

        XCTAssertEqual(config.mode, .default)
    }

    func test_defaultVersion() {
        let config = NetworkConfiguration(baseURL: testURL)

        XCTAssertEqual(config.appVersion, "1")
    }

    func test_customEndpointPaths() {
        let customPaths = EndpointPaths(
            objects: "fetchData",
            statistics: "getStats",
            analytics: "trackEvent"
        )
        let config = NetworkConfiguration(
            baseURL: testURL,
            endpointPaths: customPaths
        )

        XCTAssertEqual(config.endpointPaths.objects, "fetchData")
        XCTAssertEqual(config.endpointPaths.statistics, "getStats")
        XCTAssertEqual(config.endpointPaths.analytics, "trackEvent")
    }
}
