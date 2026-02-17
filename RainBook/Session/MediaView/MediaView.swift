import SwiftUI
import WebKit

struct MediaView: UIViewRepresentable {

    let url: URL
    @Binding var isLoading: Bool
    let onMediaViewCreated: (WKWebView) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.loadedURL = url
        context.coordinator.hasLoaded = true
        
        Task { @MainActor in
            onMediaViewCreated(webView)
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: MediaView
        var hasLoaded = false
        var loadedURL: URL?
        private var currentLoadingState = false

        init(_ parent: MediaView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if !currentLoadingState {
                currentLoadingState = true
                parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadedURL = webView.url
            if currentLoadingState {
                currentLoadingState = false
                parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if currentLoadingState {
                currentLoadingState = false
                parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if currentLoadingState {
                currentLoadingState = false
                parent.isLoading = false
            }
        }
    }
}
