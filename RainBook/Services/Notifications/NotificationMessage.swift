import Foundation

public struct NotificationMessage: Hashable, Sendable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

public protocol NotificationMessagesProviding {
    var messages: [NotificationMessage] { get }
}

public struct DailyNotificationSchedule: Hashable, Sendable {
    public let identifier: String
    public let hour: Int
    public let minute: Int

    public init(identifier: String, hour: Int, minute: Int) {
        self.identifier = identifier
        self.hour = hour
        self.minute = minute
    }
}

public extension DailyNotificationSchedule {
    static let standard: [DailyNotificationSchedule] = [
        .init(identifier: "daily-10-00", hour: 10, minute: 0),
        .init(identifier: "daily-13-00", hour: 13, minute: 0),
        .init(identifier: "daily-19-00", hour: 19, minute: 0),
        .init(identifier: "daily-22-30", hour: 22, minute: 30)
    ]
}
