import Foundation
import Combine

enum SessionTab: Hashable {
    case feature1
    case feature2
    case feature3
    case feature4
}

@MainActor
protocol SessionCoordinatorElementsFactory:
    Feature1CoordinatorElementsFactory,
    Feature2CoordinatorElementsFactory,
    Feature3CoordinatorElementsFactory,
    Feature4CoordinatorElementsFactory {}

@MainActor
final class SessionCoordinator: ObservableObject {

    @Published var selectedTab: SessionTab = .feature1
    private let feature1Service: Feature1Service
    private let notificationsService: NotificationsService
    private var hasRequestedNotifications = false

    init(feature1Service: Feature1Service, notificationsService: NotificationsService) {
        self.feature1Service = feature1Service
        self.notificationsService = notificationsService
    }

    convenience init() {
        self.init(feature1Service: Feature1Service(), notificationsService: NotificationsService())
    }

    func buildFeature1Coordinator() -> Feature1Coordinator {
        Feature1Coordinator(
            navigation: Feature1CoordinatorNavigation(),
            elementsFactory: self
        )
    }

    func buildFeature2Coordinator() -> Feature2Coordinator {
        Feature2Coordinator(
            navigation: Feature2CoordinatorNavigation(),
            elementsFactory: self
        )
    }

    func buildFeature3Coordinator() -> Feature3Coordinator {
        Feature3Coordinator(
            navigation: Feature3CoordinatorNavigation(),
            elementsFactory: self
        )
    }
    
    func buildFeature4Coordinator() -> Feature4Coordinator {
        Feature4Coordinator(
            navigation: Feature4CoordinatorNavigation(),
            elementsFactory: self
        )
    }
}

extension SessionCoordinator: Feature1CoordinatorElementsFactory {
    func feature1VM() -> Feature1VM {
        Feature1VM(service: feature1Service)
    }

    func feature1DayInfoVM(selectedDate: Date) -> Feature1DayInfoVM {
        Feature1DayInfoVM(service: feature1Service, selectedDate: selectedDate)
    }

    func feature1DetailVM(existingRecord: WeatherData?) -> Feature1DetailVM {
        Feature1DetailVM(service: feature1Service, existingRecord: existingRecord)
    }
}

extension SessionCoordinator: Feature2CoordinatorElementsFactory {
    func feature2VM() -> Feature2VM {
        Feature2VM(service: feature1Service)
    }
}

extension SessionCoordinator: Feature3CoordinatorElementsFactory {
    func feature3VM() -> Feature3VM {
        Feature3VM(service: feature1Service)
    }
}

extension SessionCoordinator: Feature4CoordinatorElementsFactory {
    func feature4VM() -> Feature4VM {
        Feature4VM()
    }
}
