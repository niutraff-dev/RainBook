import UIKit
import WebKit

final class WebViewCoordinator: NSObject {

    private let store: SafariWebStore
    private let configuration: SafariConfiguration
    private let navigationPolicy: SafariNavigationPolicy
    var loadedURL: URL?

    init(
        store: SafariWebStore,
        configuration: SafariConfiguration,
        navigationPolicy: SafariNavigationPolicy
    ) {
        self.store = store
        self.configuration = configuration
        self.navigationPolicy = navigationPolicy
    }
}

extension WebViewCoordinator: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        Task { @MainActor in
            store.setLoading(true)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            store.setLoading(false)
        }
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        Task { @MainActor in
            store.setLoading(false)
        }
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        Task { @MainActor in
            store.setLoading(false)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true

        Task { @MainActor [weak self] in
            guard let self else {
                decisionHandler(.allow)
                return
            }

            let decision = self.navigationPolicy.decidePolicy(
                for: url,
                isMainFrame: isMainFrame,
                isNewWindow: false
            )

            switch decision {
            case .allow:
                decisionHandler(.allow)

            case .cancel:
                decisionHandler(.cancel)

            case .openInExternalWebView:
                self.store.openInExternalWebView(url)
                decisionHandler(.cancel)

            case .openInSafari:
                self.store.openInSafari(url)
                decisionHandler(.cancel)

            case .openInSystemBrowser:
                if UIApplication.shared.canOpenURL(url) {
                    await UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(.performDefaultHandling, nil)
    }
}

extension WebViewCoordinator: WKUIDelegate {

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil,
              let url = navigationAction.request.url else {
            return nil
        }

        Task { @MainActor [weak self] in
            guard let self else { return }

            let decision = self.navigationPolicy.decidePolicy(
                for: url,
                isMainFrame: true,
                isNewWindow: true
            )

            switch decision {
            case .allow:
                webView.load(navigationAction.request)

            case .openInSafari:
                UIApplication.shared.open(
                    url,
                    options: [.universalLinksOnly: true]
                ) { [weak self] success in
                    if !success {
                        Task { @MainActor in
                            self?.store.openInSafari(url)
                        }
                    }
                }

            case .openInExternalWebView:
                self.store.openInExternalWebView(url)

            case .openInSystemBrowser:
                await UIApplication.shared.open(url)

            case .cancel:
                break
            }
        }

        return nil
    }
}

extension WebViewCoordinator: UIScrollViewDelegate {

    func scrollViewWillBeginZooming(
        _ scrollView: UIScrollView,
        with view: UIView?
    ) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
