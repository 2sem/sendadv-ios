//
//  Color+.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI

extension Color {
    static let background = Color("Colors/background")
    static let accent = Color("Colors/accent")
    static let title = Color("Colors/title")
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
