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

    @Published public var externalSafariViewURL: URL?

    private var safariView: WKWebView?
    private var observations: [NSKeyValueObservation] = []

    public init() {}

    public func goBack() {
        safariView?.goBack()
    }

    public func goForward() {
        safariView?.goForward()
    }

    public func reload() {
        safariView?.reload()
    }

    public func load(_ url: URL) {
        safariView?.load(URLRequest(url: url))
    }

    public func stopLoading() {
        safariView?.stopLoading()
    }

    func setWebView(_ webView: WKWebView) {
        self.safariView = webView
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

    func openInExternalSafariView(_ url: URL) {
        externalSafariViewURL = url
    }

    private func setupObservations(for safariView: WKWebView) {
        observations.removeAll()

        observations.append(
            safariView.observe(\.canGoBack, options: [.new]) { [weak self] safariView, _ in
                Task { @MainActor [weak self] in
                    self?.canGoBack = safariView.canGoBack
                }
            }
        )

        observations.append(
            safariView.observe(\.canGoForward, options: [.new]) { [weak self] safariView, _ in
                Task { @MainActor [weak self] in
                    self?.canGoForward = safariView.canGoForward
                }
            }
        )

        observations.append(
            safariView.observe(\.isLoading, options: [.new]) { [weak self] safariView, _ in
                Task { @MainActor [weak self] in
                    self?.isLoading = safariView.isLoading
                }
            }
        )

        observations.append(
            safariView.observe(\.url, options: [.new]) { [weak self] safariView, _ in
                Task { @MainActor [weak self] in
                    self?.currentURL = safariView.url
                }
            }
        )
    }
}
