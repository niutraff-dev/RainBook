import SwiftUI

struct ExternalSafariViewSheetModifier: ViewModifier {

    @ObservedObject var store: SafariWebStore
    @ObservedObject var externalStore: SafariWebStore
    let configuration: SafariConfiguration
    let closeButtonTitle: String

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: Binding(
                get: { store.externalSafariViewURL != nil },
                set: { if !$0 { store.externalSafariViewURL = nil } }
            )
        ) {
            if let url = store.externalSafariViewURL {
                NavigationView {
                    SafariViewRepresentable(
                        url: url,
                        store: externalStore,
                        configuration: externalConfiguration,
                        navigationPolicy: DefaultNavigationPolicy()
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(closeButtonTitle) {
                                store.externalSafariViewURL = nil
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
        modifier(ExternalSafariViewSheetModifier(
            store: store,
            externalStore: externalStore,
            configuration: configuration,
            closeButtonTitle: closeButtonTitle
        ))
    }
}
