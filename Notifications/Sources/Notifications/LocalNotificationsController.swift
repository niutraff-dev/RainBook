import Foundation
import UserNotifications

public protocol LocalNotificationsControlling {
    @discardableResult
    func requestAuthorization() async -> Bool
    func scheduleDailyNotifications() async
    func scheduleTestNotifications() async
    func removeDailyNotifications() async
}

public final class DefaultLocalNotificationsController: NSObject, LocalNotificationsControlling, UNUserNotificationCenterDelegate {

    private let center: UNUserNotificationCenter
    private let messagesProvider: NotificationMessagesProviding
    private let schedule: [DailyNotificationSchedule]

    public init(
        messagesProvider: NotificationMessagesProviding,
        schedule: [DailyNotificationSchedule] = DailyNotificationSchedule.standard,
        center: UNUserNotificationCenter = .current()
    ) {
        self.center = center
        self.messagesProvider = messagesProvider
        self.schedule = schedule
        super.init()
        self.center.delegate = self
    }

    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    public func scheduleDailyNotifications() async {
        guard await hasAuthorization else { return }
        await removeDailyNotifications()

        let allMessages = messagesProvider.messages
        guard !allMessages.isEmpty else { return }

        var availableMessages = allMessages.shuffled()

        for item in schedule {
            if availableMessages.isEmpty {
                availableMessages = allMessages.shuffled()
            }

            let message = availableMessages.removeFirst()
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = UNNotificationSound(named: UNNotificationSoundName("win.wav"))

            var components = DateComponents()
            components.hour = item.hour
            components.minute = item.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: item.identifier, content: content, trigger: trigger)

            do {
                try await add(request)
            } catch {
                continue
            }
        }
    }

    public func scheduleTestNotifications() async {
        guard await hasAuthorization else { return }

        let testIdentifiers = (1...4).map { "test-\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: testIdentifiers)
        center.removeDeliveredNotifications(withIdentifiers: testIdentifiers)

        var availableMessages = messagesProvider.messages.shuffled()

        for (index, identifier) in testIdentifiers.enumerated() {
            if availableMessages.isEmpty {
                availableMessages = messagesProvider.messages.shuffled()
            }

            let message = availableMessages.removeFirst()
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = UNNotificationSound(named: UNNotificationSoundName("win.wav"))

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval((index + 1) * 5),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await add(request)
            } catch {
                continue
            }
        }
    }

    public func removeDailyNotifications() async {
        let identifiers = schedule.map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .sound, .banner])
    }

    private var hasAuthorization: Bool {
        get async {
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                return true
            case .notDetermined, .denied:
                return false
            @unknown default:
                return false
            }
        }
    }

    private func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }
}
