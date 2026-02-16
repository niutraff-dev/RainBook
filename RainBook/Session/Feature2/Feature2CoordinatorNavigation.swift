import SwiftUI
import Combine

final class Feature2CoordinatorNavigation: NavigationStorable {

    enum Screen: ScreenIdentifiable {
        case main(Feature2VM)
        case detail(Feature1DetailVM)

        var screenID: ObjectIdentifier {
            switch self {
            case .main(let vm):
                return ObjectIdentifier(vm)
            case .detail(let vm):
                return ObjectIdentifier(vm)
            }
        }
    }

    @Published var path: NavigationPath = NavigationPath()

    @ViewBuilder
    func view(for screen: Screen) -> some View {
        switch screen {
        case .main(let vm):
            Feature2View(viewModel: vm)
        case .detail(let vm):
            Feature1DetailView(viewModel: vm)
        }
    }
}
