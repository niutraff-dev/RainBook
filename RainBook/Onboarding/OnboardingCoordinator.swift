import Foundation
import Combine
import SwiftUI

@MainActor
protocol OnboardingCoordinatorElementsFactory {
    func onboarding1VM() -> Onboarding1VM
    func onboarding2VM() -> Onboarding2VM
}

@MainActor
final class OnboardingCoordinator: ObservableObject {

    struct Output {
        let onFinished: () -> Void
    }

    var output: Output?

    private let elementsFactory: OnboardingCoordinatorElementsFactory

    @Published var currentStep: Int = 0 {
        didSet {
            if currentStep < 0 {
                currentStep = 0
            } else if currentStep >= totalSteps {
                currentStep = totalSteps - 1
            }
        }
    }

    let totalSteps: Int = 2

    private var _step1VM: Onboarding1VM?
    private var _step2VM: Onboarding2VM?

    var step1VM: Onboarding1VM {
        if let vm = _step1VM { return vm }
        let vm = elementsFactory.onboarding1VM()
        vm.output = .init(onNext: { [weak self] in self?.next() })
        _step1VM = vm
        return vm
    }

    var step2VM: Onboarding2VM {
        if let vm = _step2VM { return vm }
        let vm = elementsFactory.onboarding2VM()
        vm.output = .init(onNext: { [weak self] in self?.next() })
        _step2VM = vm
        return vm
    }

    init(elementsFactory: OnboardingCoordinatorElementsFactory) {
        self.elementsFactory = elementsFactory
    }

    func next() {
        let nextStep = currentStep + 1

        if nextStep >= totalSteps {
            output?.onFinished()
        } else {
            currentStep = nextStep
        }
    }

    func goToStep(_ step: Int) {
        guard (0..<totalSteps).contains(step) else { return }
        currentStep = step
    }

    func skip() {
        output?.onFinished()
    }
}
