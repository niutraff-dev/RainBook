import SwiftUI

struct Feature3CoordinatorView: View {

    @ObservedObject var coordinator: Feature3Coordinator

    var body: some View {
        NavigationStorableView(navigation: coordinator.navigation) {
            coordinator.showMain()
        }
    }
}
