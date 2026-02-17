import SwiftUI

struct WebToolbar: View {

    @ObservedObject var store: SafariWebStore

    var body: some View {
        HStack(spacing: 0) {
            Button {
                store.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!store.canGoBack)

            Button {
                store.goForward()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!store.canGoForward)

            Spacer()
                .frame(maxWidth: .infinity)

            Button {
                store.reload()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.system(size: 20))
        .frame(height: 44)
        .background(Color(UIColor.systemBackground))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
