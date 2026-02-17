import Foundation
import Combine
import WebKit

@MainActor
public final class SafariWebStore: ObservableObject {

    @Published public private(set) var canGoBack: Bool = false

    @Published public private(set) var canGoForward: Bool = false

    @Published public private(set) var currentURL: URL?

    @Published public private(set) var isLoading: Bool = false

    @Published public private(set) var isInitializing: Bool = false

    @Published public private(set) var isInitialized: Bool = false

    @Published public var safariURL: URL?

    @Published public var externalWebViewURL: URL?

    private var webView: WKWebView?
    private var observations: [NSKeyValueObservation] = []

    public init() {}

    public func goBack() {
        webView?.goBack()
    }

    public func goForward() {
        webView?.goForward()
    }

    public func reload() {
        webView?.reload()
    }

    public func load(_ url: URL) {
        webView?.load(URLRequest(url: url))
    }

    public func stopLoading() {
        webView?.stopLoading()
    }

    func setWebView(_ webView: WKWebView) {
        self.webView = webView
        self.isInitialized = true
        setupObservations(for: webView)
    }

    func setInitializing(_ value: Bool) {
        isInitializing = value
    }

    func setLoading(_ value: Bool) {
        isLoading = value
    }

    func openInSafari(_ url: URL) {
        safariURL = url
    }

    func openInExternalWebView(_ url: URL) {
        externalWebViewURL = url
    }

    private func setupObservations(for webView: WKWebView) {
        observations.removeAll()

        observations.append(
            webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                Task { @MainActor [weak self] in
                    self?.canGoBack = webView.canGoBack
                }
            }
        )

        observations.append(
            webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
                Task { @MainActor [weak self] in
                    self?.canGoForward = webView.canGoForward
                }
            }
        )

        observations.append(
            webView.observe(\.isLoading, options: [.new]) { [weak self] webView, _ in
                Task { @MainActor [weak self] in
                    self?.isLoading = webView.isLoading
                }
            }
        )

        observations.append(
            webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
                Task { @MainActor [weak self] in
                    self?.currentURL = webView.url
                }
            }
        )
    }
}
