import Foundation

final class DefaultsStorage: KeyValueStorable, @unchecked Sendable {

    static let shared = DefaultsStorage()

    private nonisolated(unsafe) let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bool(forKey key: KeyValueStorageKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    func string(forKey key: KeyValueStorageKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    func data(forKey key: KeyValueStorageKey) -> Data? {
        defaults.data(forKey: key.rawValue)
    }

    func value<T>(forKey key: KeyValueStorageKey) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }

    func set(_ value: Any?, forKey key: KeyValueStorageKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    func remove(forKey key: KeyValueStorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
