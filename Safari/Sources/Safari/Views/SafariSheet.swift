import SwiftUI
import SafariServices

struct SafariSheetModifier: ViewModifier {

    @ObservedObject var store: SafariWebStore

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: Binding(
                get: { store.safariURL != nil },
                set: { if !$0 { store.safariURL = nil } }
            )
        ) {
            if let url = store.safariURL {
                SafariViewControllerRepresentable(url: url) {
                    store.safariURL = nil
                }
                .ignoresSafeArea()
            }
        }
    }
}


struct SafariViewControllerRepresentable: UIViewControllerRepresentable {

    let url: URL
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var onDismiss: (() -> Void)?

        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onDismiss?()
        }
    }
}


extension View {
    func safariSheet(store: SafariWebStore) -> some View {
        modifier(SafariSheetModifier(store: store))
    }
}
