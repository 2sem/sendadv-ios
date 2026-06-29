//
//  Color+.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import UIKit

extension Color {
    static let background = Color("Colors/background")
    static let accent = Color("Colors/accent")
    static let title = Color("Colors/title")
    static let accentButtonLabel = Color("Colors/accentButtonLabel")
}

extension Color {
	static let softBackground = Color.dynamic(light: "#FAF6F0", dark: "#17141F")
	static let softSurface = Color.dynamic(light: "#FFFFFF", dark: "#242033")
	static let softSurfaceElevated = Color.dynamic(light: "#FFFDF9", dark: "#2B263A")
	static let softPrimaryText = Color.dynamic(light: "#2A2438", dark: "#F3F0F8")
	static let softSecondaryText = Color.dynamic(light: "#746B82", dark: "#C8C1D4")
	static let softAccent = Color.dynamic(light: "#5B5BD6", dark: "#7C6BF0")
	static let softAccentLabel = Color.dynamic(light: "#FFFFFF", dark: "#F7F4FF")
	static let softJobTint = Color.dynamic(light: "#E9E7FF", dark: "#38315E")
	static let softDepartmentTint = Color.dynamic(light: "#FFE8DA", dark: "#553527")
	static let softOrganizationTint = Color.dynamic(light: "#DDF4E8", dark: "#254838")
	static let softDivider = Color.dynamic(light: "#E8DED4", dark: "#383248")

	static func dynamic(light: String, dark: String) -> Color {
		Color(uiColor: UIColor { traitCollection in
			let hex = traitCollection.userInterfaceStyle == .dark ? dark : light
			return UIColor(hex: hex)
		})
	}
}

// HEX 컬러 지원 확장
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

private extension UIColor {
	convenience init(hex: String) {
		let scanner = Scanner(string: hex)
		_ = scanner.scanString("#")
		var rgb: UInt64 = 0
		scanner.scanHexInt64(&rgb)
		let r = CGFloat((rgb >> 16) & 0xFF) / 255
		let g = CGFloat((rgb >> 8) & 0xFF) / 255
		let b = CGFloat(rgb & 0xFF) / 255
		self.init(red: r, green: g, blue: b, alpha: 1)
	}
}
