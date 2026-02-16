import Foundation

enum KeyValueStorageKey: String {
    case onboardingShown = "onboarding_shown"
    case record_data = "record_data"
}

protocol KeyValueStorable {
    func bool(forKey key: KeyValueStorageKey) -> Bool
    func string(forKey key: KeyValueStorageKey) -> String?
    func data(forKey key: KeyValueStorageKey) -> Data?
    func value<T>(forKey key: KeyValueStorageKey) -> T?
    func set(_ value: Any?, forKey key: KeyValueStorageKey)
    func remove(forKey key: KeyValueStorageKey)
}
