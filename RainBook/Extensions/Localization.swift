import SwiftUI

enum L10n {

    enum common {
        static let ok = LocalizedStringKey("common.ok")
        static let cancel = LocalizedStringKey("common.cancel")
        static let done = LocalizedStringKey("common.done")
        static let save = LocalizedStringKey("common.save")
        static let delete = LocalizedStringKey("common.delete")
        static let edit = LocalizedStringKey("common.edit")
        static let close = LocalizedStringKey("common.close")
        static let back = LocalizedStringKey("common.back")
        static let next = LocalizedStringKey("common.next")
        static let `continue` = LocalizedStringKey("common.continue")
        static let retry = LocalizedStringKey("common.retry")
        static let loading = LocalizedStringKey("common.loading")
        static let error = LocalizedStringKey("common.error")
        static let success = LocalizedStringKey("common.success")
        static let complete = LocalizedStringKey("common.complete")
    }

    enum onboarding {
        enum welcome {
            static let title = LocalizedStringKey("onboarding.welcome.title")
            static let subtitle = LocalizedStringKey("onboarding.welcome.subtitle")
        }

        enum step1 {
            static let title = LocalizedStringKey("onboarding.step1.title")
            static let description = LocalizedStringKey("onboarding.step1.description")
        }

        enum step2 {
            static let title = LocalizedStringKey("onboarding.step2.title")
            static let description = LocalizedStringKey("onboarding.step2.description")
        }

        enum step3 {
            static let title = LocalizedStringKey("onboarding.step3.title")
            static let description = LocalizedStringKey("onboarding.step3.description")
        }

        static let getStarted = LocalizedStringKey("onboarding.getStarted")
        static let skip = LocalizedStringKey("onboarding.skip")
    }

    enum tab {
        static let feature1 = LocalizedStringKey("tab.feature1")
        static let feature2 = LocalizedStringKey("tab.feature2")
        static let feature3 = LocalizedStringKey("tab.feature3")
    }

    enum feature1 {
        static let title = LocalizedStringKey("feature1.title")
        static let empty = LocalizedStringKey("feature1.empty")

        enum detail {
            static let title = LocalizedStringKey("feature1.detail.title")
            static let content = LocalizedStringKey("feature1.detail.content")
        }
    }

    enum feature2 {
        static let title = LocalizedStringKey("feature2.title")
        static let placeholder = LocalizedStringKey("feature2.placeholder")
        static let noResults = LocalizedStringKey("feature2.noResults")

        enum detail {
            static let title = LocalizedStringKey("feature2.detail.title")
            static let content = LocalizedStringKey("feature2.detail.content")
        }
    }

    enum feature3 {
        static let title = LocalizedStringKey("feature3.title")
        static let settings = LocalizedStringKey("feature3.settings")
        static let logout = LocalizedStringKey("feature3.logout")

        enum detail {
            static let title = LocalizedStringKey("feature3.detail.title")
            static let content = LocalizedStringKey("feature3.detail.content")
        }

        enum subFlow {
            enum step1 {
                static let title = LocalizedStringKey("feature3.subFlow.step1.title")
                static let subtitle = LocalizedStringKey("feature3.subFlow.step1.subtitle")
            }

            enum step2 {
                static let title = LocalizedStringKey("feature3.subFlow.step2.title")
                static let subtitle = LocalizedStringKey("feature3.subFlow.step2.subtitle")
            }
        }
    }

    enum error {
        static let generic = LocalizedStringKey("error.generic")
        static let network = LocalizedStringKey("error.network")
        static let server = LocalizedStringKey("error.server")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(key, comment: ""), arguments: arguments)
    }
}

extension LocalizedStringKey {
    var string: String {
        let mirror = Mirror(reflecting: self)
        if let key = mirror.children.first(where: { $0.label == "key" })?.value as? String {
            return NSLocalizedString(key, comment: "")
        }
        return ""
    }
}
