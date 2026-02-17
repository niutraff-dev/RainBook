import SwiftUI
import Combine

final class Feature1CoordinatorNavigation: NavigationStorable {

    enum Screen: ScreenIdentifiable {
        case main(Feature1VM)
        case dayInfo(Feature1DayInfoVM)
        case detail(Feature1DetailVM)

        var screenID: ObjectIdentifier {
            switch self {
            case .main(let vm):
                return ObjectIdentifier(vm)
            case .dayInfo(let vm):
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
            Feature1View(viewModel: vm)
        case .dayInfo(let vm):
            Feature1DayInfoView(viewModel: vm)
        case .detail(let vm):
            Feature1DetailView(viewModel: vm)
        }
    }
}
