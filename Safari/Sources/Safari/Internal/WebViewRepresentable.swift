import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {

    let url: URL
    let store: SafariWebStore
    let configuration: SafariConfiguration
    let navigationPolicy: SafariNavigationPolicy

    private static var sharedEphemeralStore: WKWebsiteDataStore = .nonPersistent()

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = configuration.isBackgroundTransparent ? .clear : .white

        scheduleWebViewCreation(in: containerView, with: context)

        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        guard store.isInitialized,
              let webView = containerView.subviews.first(where: { $0 is WKWebView }) as? WKWebView,
              context.coordinator.loadedURL != url else {
            return
        }

        context.coordinator.loadedURL = url
        webView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(
            store: store,
            configuration: configuration,
            navigationPolicy: navigationPolicy
        )
    }

    private func scheduleWebViewCreation(
        in containerView: UIView,
        with context: UIViewRepresentableContext<WebViewRepresentable>
    ) {
        Task { @MainActor in
            store.setInitializing(true)
            await Task.yield()

            let dataStore = configuration.usesEphemeralStorage
                ? Self.sharedEphemeralStore
                : .default()

            let webView = WebViewFactory.makeWebView(
                frame: containerView.bounds,
                configuration: configuration,
                dataStore: dataStore
            )

            webView.navigationDelegate = context.coordinator
            webView.uiDelegate = context.coordinator

            if configuration.isZoomDisabled {
                webView.scrollView.delegate = context.coordinator
            }

            containerView.addSubview(webView)

            context.coordinator.loadedURL = url
            store.setWebView(webView)

            webView.load(URLRequest(url: url))

            store.setInitializing(false)
        }
    }
}
