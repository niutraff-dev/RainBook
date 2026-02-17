import Foundation

struct SettingsData: Identifiable {
    var id = UUID()
    var titel: String
    var link: URL
}

struct AppInfo {
    struct URLs {
        static let privacyLink = URL(string: "https://www.freeprivacypolicy.com/live/8fad121f-93da-4a7f-bcb6-510fa43be1a4")!
        static let termsLink = URL(string: "https://www.freeprivacypolicy.com/live/77850fa2-0cd1-4542-9b0c-a2011b4b2379")!
        static let infoLink = URL(string: "https://landing.rainfall-records.info")!
    }
}


