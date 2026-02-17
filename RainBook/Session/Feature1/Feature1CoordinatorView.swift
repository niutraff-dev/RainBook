import SwiftUI

struct Feature1CoordinatorView: View {

    @ObservedObject var coordinator: Feature1Coordinator

    var body: some View {
        NavigationStorableView(navigation: coordinator.navigation) {
            coordinator.showMain()
        }
    }
}
