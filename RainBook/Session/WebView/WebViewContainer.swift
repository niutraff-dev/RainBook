import SwiftUI
import Safari

struct WebViewContainer: View {

    @StateObject private var viewModel: WebViewModel

    init(url: URL) {
        self._viewModel = StateObject(wrappedValue: WebViewModel(url: url))
    }

    var body: some View {
        VStack(spacing: 0) {
            WebView(
                url: viewModel.url,
                isLoading: $viewModel.isLoading,
                onWebViewCreated: { webView in
                    viewModel.setWebView(webView)
                }
            )
            
            webToolbar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.palette(.backColor))
        .overlay(content: {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        })
    }
    
    @ViewBuilder
    private var webToolbar: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.canGoBack ? Color.palette(.black900) : Color.palette(.black500))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .disabled(!viewModel.canGoBack)
            
            Button {
                viewModel.goForward()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.canGoBack ? Color.palette(.black900) : Color.palette(.black500))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .disabled(!viewModel.canGoForward)
            
            Spacer()
                .frame(maxWidth: .infinity)
            
            Button {
                viewModel.reload()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.palette(.black900))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
        .background(Color.palette(.backColor))
        .overlay(alignment: .top) {
            Divider()
                .background(Color.white.opacity(0.1))
        }
    }
}

#Preview {
    WebViewContainer(url: URL(string: "https://apple.com")!)
}
