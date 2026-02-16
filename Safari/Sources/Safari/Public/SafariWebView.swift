import SwiftUI

public struct SafariWebView: View {

    private let url: URL
    private let configuration: SafariConfiguration
    private let navigationPolicy: SafariNavigationPolicy?
    private let closeButtonTitle: String

    @StateObject private var store: SafariWebStore
    @StateObject private var externalStore = SafariWebStore()

    private let externalStoreProvided: SafariWebStore?

    public init(url: URL) {
        self.url = url
        self.configuration = .default
        self.navigationPolicy = nil
        self.closeButtonTitle = "Close"
        self._store = StateObject(wrappedValue: SafariWebStore())
        self.externalStoreProvided = nil
    }

    public init(
        url: URL,
        configuration: SafariConfiguration,
        navigationPolicy: SafariNavigationPolicy? = nil,
        closeButtonTitle: String = "Close"
    ) {
        self.url = url
        self.configuration = configuration
        self.navigationPolicy = navigationPolicy
        self.closeButtonTitle = closeButtonTitle
        self._store = StateObject(wrappedValue: SafariWebStore())
        self.externalStoreProvided = nil
    }

    public init(
        url: URL,
        store: SafariWebStore,
        configuration: SafariConfiguration = .default,
        navigationPolicy: SafariNavigationPolicy? = nil,
        closeButtonTitle: String = "Close"
    ) {
        self.url = url
        self.configuration = configuration
        self.navigationPolicy = navigationPolicy
        self.closeButtonTitle = closeButtonTitle
        self._store = StateObject(wrappedValue: store)
        self.externalStoreProvided = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                WebViewRepresentable(
                    url: url,
                    store: store,
                    configuration: configuration,
                    navigationPolicy: navigationPolicy ?? DefaultNavigationPolicy()
                )

                loadingOverlay
            }

            if configuration.showsToolbar {
                WebToolbar(store: store)
            }
        }
        .safariSheet(store: store)
        .externalWebViewSheet(
            store: store,
            externalStore: externalStore,
            configuration: configuration,
            closeButtonTitle: closeButtonTitle
        )
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if configuration.showsLoadingIndicator {
            if store.isInitializing {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)

                    if let text = configuration.loadingText {
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    configuration.isBackgroundTransparent
                        ? Color.clear
                        : Color(UIColor.systemBackground)
                )
            } else if store.isInitialized && store.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}
