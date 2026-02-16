import SwiftUI

struct Feature2CoordinatorView: View {

    @ObservedObject var coordinator: Feature2Coordinator

    var body: some View {
        NavigationStorableView(navigation: coordinator.navigation) {
            coordinator.showMain()
        }
    }
}
