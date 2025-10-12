import SwiftUI

/// Constants used in TechTive's design system such as colors, fonts, etc.
enum Constants {
    /// API Configuration
    enum API {
        static let baseURL = "http://18.191.173.127:5000"

        // Notes endpoints
        static let notes = "/api/note/"
        static let note = "/api/note/"

        // Weekly advice endpoints
        static let advice = "/api/advice/latest/"

        // Profile picture endpoints
        static let profilePicture = "/api/pfp/"
    }

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

        static let profileOrange = UIColor.orange
    }

    /// Fonts used in TechTive's design system
    enum Fonts {
        // Poppins Regular
        static let poppinsRegular12 = Font.custom("Poppins-Regular", size: 12)
        static let poppinsRegular14 = Font.custom("Poppins-Regular", size: 14)
        static let poppinsRegular16 = Font.custom("Poppins-Regular", size: 16)
        static let poppinsRegular18 = Font.custom("Poppins-Regular", size: 18)
        static let poppinsRegular20 = Font.custom("Poppins-Regular", size: 20)
        static let poppinsRegular24 = Font.custom("Poppins-Regular", size: 24)
        static let poppinsRegular30 = Font.custom("Poppins-Regular", size: 30)
        static let poppinsRegular32 = Font.custom("Poppins-Regular", size: 32)

        // Poppins Medium
        static let poppinsMedium14 = Font.custom("Poppins-Medium", size: 14)
        static let poppinsMedium16 = Font.custom("Poppins-Medium", size: 16)
        static let poppinsMedium20 = Font.custom("Poppins-Medium", size: 20)
        static let poppinsMedium24 = Font.custom("Poppins-Medium", size: 24)
        static let poppinsMedium30 = Font.custom("Poppins-Medium", size: 30)

        // Poppins SemiBold
        static let poppinsSemiBold12 = Font.custom("Poppins-SemiBold", size: 12)
        static let poppinsSemiBold14 = Font.custom("Poppins-SemiBold", size: 14)
        static let poppinsSemiBold16 = Font.custom("Poppins-SemiBold", size: 16)
        static let poppinsSemiBold20 = Font.custom("Poppins-SemiBold", size: 20)
        static let poppinsSemiBold24 = Font.custom("Poppins-SemiBold", size: 24)
        static let poppinsSemiBold32 = Font.custom("Poppins-SemiBold", size: 32)

        // Courier Prime
        static let courierPrime16 = Font.custom("CourierPrime-Regular", size: 16)
        static let courierPrime17 = Font.custom("CourierPrime-Regular", size: 17)
        static let courierPrime18 = Font.custom("CourierPrime-Regular", size: 18)

        // System Fonts
        static let system10 = Font.system(size: 10)
        static let system12 = Font.system(size: 12)
        static let system14 = Font.system(size: 14)
        static let system16 = Font.system(size: 16)
        static let system17 = Font.system(size: 17)
        static let system20 = Font.system(size: 20)
        static let system24 = Font.system(size: 24)
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
