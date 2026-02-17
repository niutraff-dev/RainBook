import Foundation
import WebKit
import Combine

@MainActor
final class MediaViewModel: ObservableObject {

    @Published var isLoading: Bool = true
    @Published var url: URL
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    private weak var mediaView: WKWebView?
    private var observations: [NSKeyValueObservation] = []
    
    init(url: URL) {
        self.url = url
    }
    
    func setMediaView(_ mediaView: WKWebView) {
        guard self.mediaView !== mediaView else { return }
        self.mediaView = mediaView
        setupObservations(for: mediaView)
        updateNavigationState()
    }
    
    func goBack() {
        mediaView?.goBack()
    }
    
    func goForward() {
        mediaView?.goForward()
    }
    
    func reload() {
        mediaView?.reload()
    }
    
    private func updateNavigationState() {
        canGoBack = mediaView?.canGoBack ?? false
        canGoForward = mediaView?.canGoForward ?? false
    }
    
    private func setupObservations(for mediaView: WKWebView) {
        observations.removeAll()
        
        observations.append(
            mediaView.observe(\.canGoBack, options: [.new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in
                    self?.updateNavigationState()
                }
            }
        )
        
        observations.append(
            mediaView.observe(\.canGoForward, options: [.new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in
                    self?.updateNavigationState()
                }
            }
        )
    }
}
