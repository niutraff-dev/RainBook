import SwiftUI

struct Feature4CoordinatorView: View {

    @ObservedObject var coordinator: Feature4Coordinator

    var body: some View {
        NavigationStorableView(navigation: coordinator.navigation) {
            coordinator.showMain()
        }
    }
}
