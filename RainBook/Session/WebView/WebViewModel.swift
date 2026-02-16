import Foundation
import WebKit
import Combine

@MainActor
final class WebViewModel: ObservableObject {

    @Published var isLoading: Bool = true
    @Published var url: URL
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    private weak var webView: WKWebView?
    private var observations: [NSKeyValueObservation] = []
    
    init(url: URL) {
        self.url = url
    }
    
    func setWebView(_ webView: WKWebView) {
        guard self.webView !== webView else { return }
        self.webView = webView
        setupObservations(for: webView)
        updateNavigationState()
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func reload() {
        webView?.reload()
    }
    
    private func updateNavigationState() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
    }
    
    private func setupObservations(for webView: WKWebView) {
        observations.removeAll()
        
        observations.append(
            webView.observe(\.canGoBack, options: [.new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in
                    self?.updateNavigationState()
                }
            }
        )
        
        observations.append(
            webView.observe(\.canGoForward, options: [.new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in
                    self?.updateNavigationState()
                }
            }
        )
    }
}
