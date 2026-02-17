import SwiftUI
import Combine

@MainActor
final class Feature4VM: ObservableObject {
    @Published var settings: [SettingsData] = []
    @Published var selectedURL: URL?
    @Published var showWebView: Bool = false

    init() {
        self.setupSettings()
    }
    
    func setupSettings() {
        settings = [.rateUs, .privacyPolicy, .ternsOfCondition]
    }
    
    func openWebView(with url: URL) {
        selectedURL = url
        showWebView = true
    }
    
    func closeWebView() {
        showWebView = false
        selectedURL = nil
    }
}

extension SettingsData {
    static let rateUs: Self = .init(titel: "settings.rate".localized(), link: AppInfo.URLs.infoLink)
    static let privacyPolicy: Self = .init(titel: "settings.privacyPolicy".localized(), link: AppInfo.URLs.privacyLink)
    static let ternsOfCondition: Self = .init(titel: "settings.termsOfUse".localized(), link: AppInfo.URLs.termsLink)
}

