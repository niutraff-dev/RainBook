import SwiftUI

struct ExternalWebViewSheetModifier: ViewModifier {

    @ObservedObject var store: SafariWebStore
    @ObservedObject var externalStore: SafariWebStore
    let configuration: SafariConfiguration
    let closeButtonTitle: String

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: Binding(
                get: { store.externalWebViewURL != nil },
                set: { if !$0 { store.externalWebViewURL = nil } }
            )
        ) {
            if let url = store.externalWebViewURL {
                NavigationView {
                    WebViewRepresentable(
                        url: url,
                        store: externalStore,
                        configuration: externalConfiguration,
                        navigationPolicy: DefaultNavigationPolicy()
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(closeButtonTitle) {
                                store.externalWebViewURL = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private var externalConfiguration: SafariConfiguration {
        SafariConfiguration(
            customUserAgent: configuration.customUserAgent,
            isZoomDisabled: configuration.isZoomDisabled,
            isBackgroundTransparent: configuration.isBackgroundTransparent,
            showsToolbar: false,
            showsLoadingIndicator: false,
            usesEphemeralStorage: configuration.usesEphemeralStorage
        )
    }
}


extension View {
    func externalWebViewSheet(
        store: SafariWebStore,
        externalStore: SafariWebStore,
        configuration: SafariConfiguration,
        closeButtonTitle: String = "Close"
    ) -> some View {
        modifier(ExternalWebViewSheetModifier(
            store: store,
            externalStore: externalStore,
            configuration: configuration,
            closeButtonTitle: closeButtonTitle
        ))
    }
}
