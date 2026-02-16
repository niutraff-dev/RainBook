import SwiftUI

struct OnboardingCoordinatorView: View {

    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        TabView(selection: $coordinator.currentStep) {
            Onboarding1View(viewModel: coordinator.step1VM)
                .tag(0)

            Onboarding2View(viewModel: coordinator.step2VM)
                .tag(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.palette(.backColor))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .animation(.easeInOut, value: coordinator.currentStep)
    }
}
