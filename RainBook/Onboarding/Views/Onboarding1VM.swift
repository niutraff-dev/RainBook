import SwiftUI
import Combine

@MainActor
final class Onboarding1VM: ObservableObject {

    struct Output {
        let onNext: () -> Void
    }

    var output: Output?

    func onNextTapped() {
        output?.onNext()
    }
}
