import Foundation

final class StorageKeys {

    static let shared = StorageKeys()

    private init() {}

    let onboardingCompleted = StorageKey<Bool>(key: .onboardingShown, default: false)
}
