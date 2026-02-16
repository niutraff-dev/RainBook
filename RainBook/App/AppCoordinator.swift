import Foundation
import Combine
import Network

@MainActor
final class AppCoordinator: ObservableObject {

    enum ViewState {
        case onboarding(OnboardingCoordinator)
        case session(SessionCoordinator)
        case webView(URL)
    }

    enum Overlay {
        case splash
    }

    @Published private(set) var viewState: ViewState?
    @Published var overlay: Overlay?

    private let appStatusService: Network.AppStatusServiceProtocol
    private let analyticsRepository: Network.AnalyticsRepositoryProtocol
    private let notificationsService: NotificationsService
    private var status: Network.AppStatus?
    private var statisticsUrl: URL?

    @KeyValue(\.onboardingCompleted)
    private var isOnboardingShown: Bool

    init(
        appStatusService: Network.AppStatusServiceProtocol,
        analyticsRepository: Network.AnalyticsRepositoryProtocol,
        notificationsService: NotificationsService
    ) {
        self.appStatusService = appStatusService
        self.analyticsRepository = analyticsRepository
        self.notificationsService = notificationsService
        self.overlay = .splash
    }

    convenience init() {
        self.init(
            appStatusService: NetworkServiceFactory.makeAppStatusService(),
            analyticsRepository: NetworkServiceFactory.makeAnalyticsRepository(),
            notificationsService: NotificationsService()
        )
    }

    func onAppear() async {
        async let statusResult = appStatusService.loadStatus()
        async let analytics = analyticsRepository.sendEvent()

        let (result, _) = await (statusResult, analytics)

        statisticsUrl = result.statisticsUrl
        handleStatus(result.status)
    }

    private func handleStatus(_ status: Network.AppStatus) {
        overlay = nil
        self.status = status
        handleNotifications(for: status)

        if !isOnboardingShown {
            showOnboarding()
        } else {
            showMain()
        }
    }

    private func handleNotifications(for status: Network.AppStatus) {
        Task {
            switch status {
            case .zero:
                await notificationsService.removeDailyNotifications()
            case .one:
                Task {
                    let granted = await notificationsService.requestAuthorization()
                    if granted {
                        await notificationsService.scheduleNotifications()
                    }
                }
            }
        }
    }

    private func showMain() {
        guard let status = status else { return }

        switch status {
        case .zero:
            showSession()
        case .one(let url):
            showWebView(with: url)
        }
    }

    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(elementsFactory: self)
        coordinator.output = .init(onFinished: { [weak self] in
            self?.onOnboardingFinished()
        })
        viewState = .onboarding(coordinator)
    }

    private func onOnboardingFinished() {
        isOnboardingShown = true
        showMain()
    }

    private func showSession() {
        let coordinator = SessionCoordinator()
        viewState = .session(coordinator)
    }

    private func showWebView(with url: URL?) {
        guard let url = url else {
            showSession()
            return
        }
        viewState = .webView(url)
    }
}

extension AppCoordinator: OnboardingCoordinatorElementsFactory {
    func onboarding1VM() -> Onboarding1VM {
        Onboarding1VM()
    }

    func onboarding2VM() -> Onboarding2VM {
        Onboarding2VM()
    }
}
