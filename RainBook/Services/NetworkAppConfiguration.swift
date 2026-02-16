import Foundation
import Network

enum NetworkAppConfiguration {

    static var configuration: NetworkConfiguration {
        NetworkConfiguration(
            baseURL: URL(string: "https://rainfall-records.info")!,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            basicAuth: ("admin", "krM8O484WKml"),
            mode: appMode,
            appVersion: majorAppVersion,
            endpointPaths: EndpointPaths() 
        )
    }

    private static let appMode: NetworkMode = .combat

    private static var majorAppVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version.components(separatedBy: ".").first ?? "1"
    }
}

enum NetworkServiceFactory {

    @MainActor
    static func makeAppStatusService() -> Network.AppStatusServiceProtocol {
        NetworkFactory.makeAppStatusService(configuration: NetworkAppConfiguration.configuration)
    }

    @MainActor
    static func makeAnalyticsRepository() -> Network.AnalyticsRepositoryProtocol {
        NetworkFactory.makeAnalyticsRepository(configuration: NetworkAppConfiguration.configuration)
    }
}
