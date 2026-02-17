import WebKit

enum WebViewFactory {

    static func makeWebView(
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

        let webView = WKWebView(frame: frame, configuration: wkConfig)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let userAgent = configuration.customUserAgent {
            webView.customUserAgent = userAgent
        }

        if configuration.isBackgroundTransparent {
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
        }

        return webView
    }
}
