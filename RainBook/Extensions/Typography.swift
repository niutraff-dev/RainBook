import SwiftUI

struct Typography {

    let font: Font
    let lineSpacing: CGFloat
    let kerning: CGFloat

    init(font: Font, lineSpacing: CGFloat = 0, kerning: CGFloat = 0) {
        self.font = font
        self.lineSpacing = lineSpacing
        self.kerning = kerning
    }

    static let largeTitle = LargeTitleStyle()

    struct LargeTitleStyle {
        private let size: CGFloat = 34
        private let spacing: CGFloat = 7
        private let kern: CGFloat = 0.4

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let title1 = Title1Style()

    struct Title1Style {
        private let size: CGFloat = 28
        private let spacing: CGFloat = 6
        private let kern: CGFloat = 0.38

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let title2 = Title2Style()

    struct Title2Style {
        private let size: CGFloat = 22
        private let spacing: CGFloat = 6
        private let kern: CGFloat = -0.26

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let title3 = Title3Style()

    struct Title3Style {
        private let size: CGFloat = 20
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.45

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let headline = HeadlineStyle()

    struct HeadlineStyle {
        private let size: CGFloat = 17
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.43

        var regular: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let body = BodyStyle()

    struct BodyStyle {
        private let size: CGFloat = 17
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.43

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let callout = CalloutStyle()

    struct CalloutStyle {
        private let size: CGFloat = 16
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.31

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let subheadline = SubheadlineStyle()

    struct SubheadlineStyle {
        private let size: CGFloat = 15
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.23

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let footnote = FootnoteStyle()

    struct FootnoteStyle {
        private let size: CGFloat = 13
        private let spacing: CGFloat = 5
        private let kern: CGFloat = -0.08

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let caption1 = Caption1Style()

    struct Caption1Style {
        private let size: CGFloat = 12
        private let spacing: CGFloat = 4
        private let kern: CGFloat = 0

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }

    static let caption2 = Caption2Style()

    struct Caption2Style {
        private let size: CGFloat = 11
        private let spacing: CGFloat = 2
        private let kern: CGFloat = 0.06

        var regular: Typography {
            Typography(font: .custom(FontFamily.regular, size: size), lineSpacing: spacing, kerning: kern)
        }
        var medium: Typography {
            Typography(font: .custom(FontFamily.medium, size: size), lineSpacing: spacing, kerning: kern)
        }
        var semibold: Typography {
            Typography(font: .custom(FontFamily.semibold, size: size), lineSpacing: spacing, kerning: kern)
        }
        var bold: Typography {
            Typography(font: .custom(FontFamily.bold, size: size), lineSpacing: spacing, kerning: kern)
        }
    }
}

enum FontFamily {
    static let regular = "SFProText-Regular"
    static let medium = "SFProText-Medium"
    static let semibold = "SFProText-Semibold"
    static let bold = "SFProText-Bold"
}

struct TypographyModifier: ViewModifier {

    let typography: Typography

    func body(content: Content) -> some View {
        content
            .font(typography.font)
            .lineSpacing(typography.lineSpacing)
            .kerning(typography.kerning)
    }
}

extension View {
    func typography(_ typography: Typography) -> some View {
        modifier(TypographyModifier(typography: typography))
    }
}
