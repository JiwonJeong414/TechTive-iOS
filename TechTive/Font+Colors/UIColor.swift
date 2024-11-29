//
//  UIColor.swift
//  TechTive
//
//  Created by jiwon jeong on 11/29/24.
//

import UIKit
import SwiftUI

extension UIColor {

    static let color = Color()

    struct Color {
        let backgroundColor = UIColor(red: 252/255, green: 247/255, blue: 241/255, alpha: 1)
        let lightYellow = UIColor(red: 255/255, green: 247/255, blue: 213/255, alpha: 1)
        let purple = UIColor(red: 243/255, green: 231/255, blue: 241/255, alpha: 1)
        let orange = UIColor(red: 236/255, green: 93/255, blue: 58/255, alpha: 1)
        let darkPurple = UIColor(red: 27/255, green: 24/255, blue: 31/255, alpha: 1)
    }

}

extension Color {
    static let background = Color(UIColor.color.backgroundColor)
    static let lightYellow = Color(UIColor.color.lightYellow)
    static let purple = Color(UIColor.color.purple)
    static let orange = Color(UIColor.color.orange)
    static let darkPurple = Color(UIColor.color.darkPurple)
}
