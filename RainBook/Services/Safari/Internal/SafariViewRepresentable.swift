import SwiftUI
import WebKit

struct SafariViewRepresentable: UIViewRepresentable {

    let url: URL
    let store: SafariWebStore
    let configuration: SafariConfiguration
    let navigationPolicy: SafariNavigationPolicy

    private static var sharedEphemeralStore: WKWebsiteDataStore = .nonPersistent()

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = configuration.isBackgroundTransparent ? .clear : .white

        scheduleSafariViewCreation(in: containerView, with: context)

        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        guard store.isInitialized,
              let safariView = containerView.subviews.first(where: { $0 is WKWebView }) as? WKWebView,
              context.coordinator.loadedURL != url else {
            return
        }

        context.coordinator.loadedURL = url
        safariView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> SafariViewCoordinator {
        SafariViewCoordinator(
            store: store,
            configuration: configuration,
            navigationPolicy: navigationPolicy
        )
    }

    private func scheduleSafariViewCreation(
        in containerView: UIView,
        with context: UIViewRepresentableContext<SafariViewRepresentable>
    ) {
        Task { @MainActor in
            store.setInitializing(true)
            await Task.yield()

            let dataStore = configuration.usesEphemeralStorage
                ? Self.sharedEphemeralStore
                : .default()

            let safariView = SafariViewFactory.makeSafariView(
                frame: containerView.bounds,
                configuration: configuration,
                dataStore: dataStore
            )

            safariView.navigationDelegate = context.coordinator
            safariView.uiDelegate = context.coordinator

            if configuration.isZoomDisabled {
                safariView.scrollView.delegate = context.coordinator
            }

            containerView.addSubview(safariView)

            context.coordinator.loadedURL = url
            store.setWebView(safariView)

            safariView.load(URLRequest(url: url))

            store.setInitializing(false)
        }
    }
}
