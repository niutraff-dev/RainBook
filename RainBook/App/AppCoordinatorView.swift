import SwiftUI

struct AppCoordinatorView: View {

    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            if let viewState = coordinator.viewState {
                content(for: viewState)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(content: overlayContent)
        .task {
            await coordinator.onAppear()
        }
    }

    @ViewBuilder
    private func content(for viewState: AppCoordinator.ViewState) -> some View {
        switch viewState {
        case .onboarding(let coordinator):
            OnboardingCoordinatorView(coordinator: coordinator)

        case .session(let coordinator):
            SessionCoordinatorView(coordinator: coordinator)

        case .webView(let url):
            WebViewContainer(url: url)
        }
    }

    @ViewBuilder
    private func overlayContent() -> some View {
        if let overlay = coordinator.overlay {
            switch overlay {
            case .splash:
                SplashView()
            }
        }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            Color.palette(.backColor)
                .ignoresSafeArea()

            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

#Preview {
    AppCoordinatorView(coordinator: AppCoordinator())
}
