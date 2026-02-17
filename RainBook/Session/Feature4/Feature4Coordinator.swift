import SwiftUI
import Combine

@MainActor
protocol Feature4CoordinatorElementsFactory {
    func feature4VM() -> Feature4VM
}

@MainActor
final class Feature4Coordinator: ObservableObject {

    let navigation: Feature4CoordinatorNavigation
    private let elementsFactory: Feature4CoordinatorElementsFactory
    private var _viewModel: Feature4VM?

    private var viewModel: Feature4VM {
        if let vm = _viewModel { return vm }
        let vm = elementsFactory.feature4VM()
        _viewModel = vm
        return vm
    }

    init(
        navigation: Feature4CoordinatorNavigation,
        elementsFactory: Feature4CoordinatorElementsFactory
    ) {
        self.navigation = navigation
        self.elementsFactory = elementsFactory
    }

    func showMain() -> some View {
        navigation.view(for: .main(viewModel))
    }
}
