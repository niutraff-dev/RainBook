import WebKit

enum SafariViewFactory {

    static func makeSafariView(
        frame: CGRect,
        configuration: SafariConfiguration,
        dataStore: WKWebsiteDataStore
    ) -> WKWebView {
        let wkConfig = WKWebViewConfiguration()
        wkConfig.websiteDataStore = dataStore

        if configuration.isZoomDisabled {
            let script = WKUserScript(
                source: ZoomDisableScript.source,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            wkConfig.userContentController.addUserScript(script)
        }

        let safariView = WKWebView(frame: frame, configuration: wkConfig)
        safariView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let userAgent = configuration.customUserAgent {
            safariView.customUserAgent = userAgent
        }

        if configuration.isBackgroundTransparent {
            safariView.isOpaque = false
            safariView.backgroundColor = .clear
            safariView.scrollView.backgroundColor = .clear
        }

        return safariView
    }
}
