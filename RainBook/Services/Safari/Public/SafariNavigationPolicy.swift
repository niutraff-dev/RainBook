import Foundation

public enum SafariNavigationDecision: Sendable {
    case allow

    case cancel

    case openInExternalWebView

    case openInSafari

    case openInSystemBrowser
}


@MainActor
public protocol SafariNavigationPolicy: AnyObject {

    func decidePolicy(
        for url: URL,
        isMainFrame: Bool,
        isNewWindow: Bool
    ) -> SafariNavigationDecision
}


@MainActor
public final class DefaultNavigationPolicy: SafariNavigationPolicy {

    public init() {}

    public func decidePolicy(
        for url: URL,
        isMainFrame: Bool,
        isNewWindow: Bool
    ) -> SafariNavigationDecision {
        guard let scheme = url.scheme?.lowercased() else {
            return .allow
        }

        if !["http", "https", "about", "blob"].contains(scheme) {
            return .openInSystemBrowser
        }

        return .allow
    }
}


@MainActor
public final class PaymentNavigationPolicy: SafariNavigationPolicy {

    public var externalPatterns: [String]

    public var paymentRedirectPatterns: [String]

    public var bankingAuthPatterns: [String]

    public init(
        externalPatterns: [String] = [
            "paymentiq", "softswiss",
            "3ds", "bthsrprsrpay", "psppaygate"
        ],
        paymentRedirectPatterns: [String] = [
            "/paymentiq/api/piq-redirect-assistance/",
            "/paymentiq/api/kluwp/redirect/"
        ],
        bankingAuthPatterns: [String] = [
            "/openbanking/", "/authorize", "/oauth", "oba."
        ]
    ) {
        self.externalPatterns = externalPatterns
        self.paymentRedirectPatterns = paymentRedirectPatterns
        self.bankingAuthPatterns = bankingAuthPatterns
    }

    public func decidePolicy(
        for url: URL,
        isMainFrame: Bool,
        isNewWindow: Bool
    ) -> SafariNavigationDecision {
        guard let scheme = url.scheme?.lowercased() else {
            return .allow
        }

        if !["http", "https", "about", "blob"].contains(scheme) {
            return .openInSystemBrowser
        }

        let urlString = url.absoluteString

        let isPaymentRedirect = paymentRedirectPatterns.contains { pattern in
            urlString.localizedCaseInsensitiveContains(pattern)
        }
        if isPaymentRedirect {
            return .openInExternalWebView
        }

        let shouldOpenExternal = externalPatterns.contains { pattern in
            urlString.localizedCaseInsensitiveContains(pattern)
        }
        if shouldOpenExternal && isMainFrame {
            return .openInExternalWebView
        }

        if isNewWindow {
            let isBankingAuth = bankingAuthPatterns.contains { pattern in
                urlString.localizedCaseInsensitiveContains(pattern)
            }
            if isBankingAuth {
                return .openInSafari
            }
            return .allow
        }

        return .allow
    }
}
