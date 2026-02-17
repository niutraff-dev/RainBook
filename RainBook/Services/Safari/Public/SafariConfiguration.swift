import Foundation

public struct SafariConfiguration: Sendable {

    public var customUserAgent: String?

    public var isZoomDisabled: Bool

    public var isBackgroundTransparent: Bool

    public var showsToolbar: Bool

    public var showsLoadingIndicator: Bool

    public var loadingText: String?

    public var usesEphemeralStorage: Bool

    public init(
        customUserAgent: String? = nil,
        isZoomDisabled: Bool = false,
        isBackgroundTransparent: Bool = false,
        showsToolbar: Bool = false,
        showsLoadingIndicator: Bool = true,
        loadingText: String? = nil,
        usesEphemeralStorage: Bool = true
    ) {
        self.customUserAgent = customUserAgent
        self.isZoomDisabled = isZoomDisabled
        self.isBackgroundTransparent = isBackgroundTransparent
        self.showsToolbar = showsToolbar
        self.showsLoadingIndicator = showsLoadingIndicator
        self.loadingText = loadingText
        self.usesEphemeralStorage = usesEphemeralStorage
    }
}
