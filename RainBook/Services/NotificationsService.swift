import Foundation
import Notifications

struct CriciumaBefairNotificationMessagesProvider: NotificationMessagesProviding {
    var messages: [NotificationMessage] {
        NotificationMessageKeys.all.map { keys in
            NotificationMessage(
                title: localized(keys.title),
                body: localized(keys.body)
            )
        }
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .main, comment: "")
    }
}

@MainActor
final class NotificationsService {

    static let isTestMode = false

    private let controller: LocalNotificationsControlling

    init(controller: LocalNotificationsControlling = DefaultLocalNotificationsController(messagesProvider: CriciumaBefairNotificationMessagesProvider())) {
        self.controller = controller
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        await controller.requestAuthorization()
    }

    func scheduleNotifications() async {
        if Self.isTestMode {
            await controller.scheduleTestNotifications()
        } else {
            await controller.scheduleDailyNotifications()
        }
    }

    func removeDailyNotifications() async {
        await controller.removeDailyNotifications()
    }
}

private enum NotificationMessageKeys {
    static let all: [(title: String, body: String)] = [
        ("notification.message1.title", "notification.message1.body"),
        ("notification.message2.title", "notification.message2.body"),
        ("notification.message3.title", "notification.message3.body"),
        ("notification.message4.title", "notification.message4.body"),
        ("notification.message5.title", "notification.message5.body"),
        ("notification.message6.title", "notification.message6.body"),
        ("notification.message7.title", "notification.message7.body"),
        ("notification.message8.title", "notification.message8.body"),
        ("notification.message9.title", "notification.message9.body"),
        ("notification.message10.title", "notification.message10.body")
    ]
}
