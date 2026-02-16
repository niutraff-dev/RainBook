import Foundation

struct StorageKey<Value: Sendable>: Sendable {
    let key: KeyValueStorageKey
    let defaultValue: Value

    init(key: KeyValueStorageKey, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
