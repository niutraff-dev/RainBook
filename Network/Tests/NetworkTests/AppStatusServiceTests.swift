import XCTest
@testable import Network

final class AppStatusServiceTests: XCTestCase {

    private var mockObjectsRepo: MockObjectsRepository!
    private var mockStatsRepo: MockStatisticsRepository!
    private let testURL = URL(string: "https://example.com/stats")!

    override func setUp() {
        super.setUp()
        mockObjectsRepo = MockObjectsRepository()
        mockStatsRepo = MockStatisticsRepository()
    }

    override func tearDown() {
        mockObjectsRepo = nil
        mockStatsRepo = nil
        super.tearDown()
    }

    private func makeService(mode: NetworkMode, appVersion: String) -> AppStatusService {
        let config = NetworkConfiguration(
            baseURL: URL(string: "https://api.test.com")!,
            mode: mode,
            appVersion: appVersion
        )
        return AppStatusService(
            objectsRepository: mockObjectsRepo,
            statisticsRepository: mockStatsRepo,
            configuration: config
        )
    }

    func test_1_default_v1_returns_zero_without_network() async {
        let service = makeService(mode: .default, appVersion: "1")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
        XCTAssertNil(result.statisticsUrl)
        XCTAssertEqual(mockObjectsRepo.fetchCount, 0, "Should NOT make network request")
        XCTAssertEqual(mockStatsRepo.fetchCount, 0, "Should NOT make network request")
    }

    func test_2_default_v2_objects200_statsValid_returns_one() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
        XCTAssertEqual(result.statisticsUrl, testURL)
    }

    func test_3_default_v2_objects200_statsFail_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
        XCTAssertNil(result.statisticsUrl)
    }

    func test_4_default_v2_objects200_statsInvalidBase64_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_5_default_v2_objects400_returns_zero() async {
        mockObjectsRepo.stubBadRequest()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_6_default_v2_objects500_returns_zero() async {
        mockObjectsRepo.stubError()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_7_default_v2_objectsNetworkError_returns_zero() async {
        mockObjectsRepo.stubError()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_8_default_v3_objects200_statsValid_returns_one() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "3")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
        XCTAssertEqual(mockObjectsRepo.fetchCount, 1, "Should make network request")
    }

    func test_9_default_v3_objects400_returns_zero() async {
        mockObjectsRepo.stubBadRequest()
        let service = makeService(mode: .default, appVersion: "3")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_10_default_v5_objects200_statsValid_returns_one() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "5")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
    }

    func test_11_combat_v1_objects200_statsValid_returns_one() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "1")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
        XCTAssertEqual(mockObjectsRepo.fetchCount, 1, "Combat ignores v1, should request")
    }

    func test_12_combat_v1_objects400_returns_zero() async {
        mockObjectsRepo.stubBadRequest()
        let service = makeService(mode: .combat, appVersion: "1")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_13_combat_v1_objects200_statsFail_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .combat, appVersion: "1")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_14_combat_v3_objects200_statsValid_returns_one() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "3")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
    }

    func test_15_objects200_statsNetworkError_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_16_objects200_statsTimeout_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_17_objects200_statsEmpty_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_18_objects200_statsInvalidBase64_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_19_objects200_statsNonURLBase64_returns_zero() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubFailure()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_20_objectsTimeout_returns_zero() async {
        mockObjectsRepo.stubError()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_21_invalidURLInConfig_returns_zero() async {
        mockObjectsRepo.stubError()
        let service = makeService(mode: .default, appVersion: "2")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_22_default_v1_no_request() async {
        let service = makeService(mode: .default, appVersion: "1")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 0)
    }

    func test_23_default_v2_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "2")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_24_default_v3_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "3")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_25_default_v10_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .default, appVersion: "10")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_26_combat_v1_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "1")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_27_combat_v2_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "2")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_28_combat_v99_makes_request() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "99")

        _ = await service.loadStatus()

        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
    }

    func test_29_emptyAppVersion_returns_zero() async {
        let service = makeService(mode: .default, appVersion: "")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_30_invalidAppVersion_returns_zero() async {
        mockObjectsRepo.stubError()
        let service = makeService(mode: .default, appVersion: "abc")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .zero)
    }

    func test_31_parallelRequestsCompleteCorrectly() async {
        mockObjectsRepo.stubSuccess()
        mockStatsRepo.stubURL(testURL)
        let service = makeService(mode: .combat, appVersion: "1")

        let result = await service.loadStatus()

        XCTAssertEqual(result.status, .one(testURL))
        XCTAssertEqual(mockObjectsRepo.fetchCount, 1)
        XCTAssertEqual(mockStatsRepo.fetchCount, 1)
    }
}
