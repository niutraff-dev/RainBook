import SwiftUI
import UIKit

enum PaletteColor: UInt {

    case black900 = 0x000000
    case black800 = 0x1A1A1A
    case black700 = 0x333333
    case black600 = 0x4D4D4D
    case black500 = 0x666666
    case black400 = 0x808080
    case black300 = 0x999999
    case black200 = 0xB3B3B3
    case black100 = 0xCCCCCC
    case black50 = 0xE6E6E6

    case white = 0xFFFFFF
    case white50 = 0xFAFAFA
    case white100 = 0xF5F5F5
    case white200 = 0xEEEEEE

    case primary900 = 0x1A237E
    case primary800 = 0x283593
    case primary700 = 0x303F9F
    case primary600 = 0x3949AB
    case primary500 = 0x3F51B5
    case primary400 = 0x5C6BC0
    case primary300 = 0x7986CB
    case primary200 = 0x9FA8DA
    case primary100 = 0xC5CAE9
    case primary50 = 0xE8EAF6

    case secondary500 = 0xFF4081
    case secondary400 = 0xFF80AB
    case secondary300 = 0xFFB3D0
    case secondary200 = 0xFFD6E8
    case secondary100 = 0xFFEBF3

    case success500 = 0x4CAF50
    case success100 = 0xC8E6C9

    case warning500 = 0xFFC107
    case warning100 = 0xFFF8E1

    case error500 = 0xF44336
    case error100 = 0xFFEBEE

    case textPrimary = 0x212121
    case textSecondary = 0x757575
    case textDisabled = 0xBDBDBD
    
    case backColor = 0xF0F1F2
    case blueColor = 0x1F85C6
    case lightGray = 0xDAE0EF
    case darkBlackColor = 0x151923

    var color: Color {
        Color(hex: rawValue)
    }

    var uiColor: UIColor {
        UIColor(hex: rawValue)
    }

    static var background: PaletteColor { .white }
    static var backgroundSecondary: PaletteColor { .white100 }
}

extension Color {
    static func palette(_ color: PaletteColor) -> Color {
        color.color
    }

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

extension UIColor {
    static func palette(_ color: PaletteColor) -> UIColor {
        color.uiColor
    }

    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
