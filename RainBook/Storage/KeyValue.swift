import Foundation

@propertyWrapper
struct KeyValue<Value: Sendable>: Sendable {

    private let storageKey: StorageKey<Value>
    private let storage: DefaultsStorage

    init(_ keyPath: KeyPath<StorageKeys, StorageKey<Value>>) {
        self.storageKey = StorageKeys.shared[keyPath: keyPath]
        self.storage = DefaultsStorage.shared
    }

    var wrappedValue: Value {
        get {
            storage.value(forKey: storageKey.key) ?? storageKey.defaultValue
        }
        nonmutating set {
            storage.set(newValue, forKey: storageKey.key)
        }
    }
}
