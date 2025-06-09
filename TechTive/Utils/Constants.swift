import SwiftUI

/// Constants used in TechTive's design system such as colors, fonts, etc.
enum Constants {
    /// Colors used in TechTive's design system
    enum Colors {
        // Primary
        static let backgroundColor = UIColor(red: 252 / 255, green: 247 / 255, blue: 241 / 255, alpha: 1)
        static let lightYellow = UIColor(red: 255 / 255, green: 247 / 255, blue: 213 / 255, alpha: 1)
        static let purple = UIColor(red: 243 / 255, green: 231 / 255, blue: 241 / 255, alpha: 1)
        static let orange = UIColor(red: 236 / 255, green: 93 / 255, blue: 58 / 255, alpha: 1)
        static let darkPurple = UIColor(red: 48 / 255, green: 28 / 255, blue: 58 / 255, alpha: 1)
        static let lightOrange = UIColor(red: 255 / 255, green: 182 / 255, blue: 123 / 255, alpha: 1)

        // Additional colors found in codebase
        static let stickyYellow = UIColor(red: 255 / 255, green: 251 / 255, blue: 181 / 255, alpha: 1)
        static let foldYellow = UIColor(red: 255 / 255, green: 244 / 255, blue: 120 / 255, alpha: 1)
        static let lightPurple = UIColor(hex: "F3E5F5")
        static let deepOrange = UIColor(hex: "E65100")
        static let warmOrange = UIColor(hex: "FFF3E0")

        // System colors that should be standardized
        static let white = UIColor.white
        static let black = UIColor.black
        static let gray = UIColor.gray
        static let red = UIColor.red
    }
}

// Extension to support hex color initialization
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
