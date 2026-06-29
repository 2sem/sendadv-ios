//
//  SoftFriendlyStyle.swift
//  App
//
//  Created by OpenAI on 6/28/26.
//

import SwiftUI

struct SoftFriendlyCardModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.background(Color.softSurface, in: .rect(cornerRadius: 28, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: 28, style: .continuous)
					.stroke(Color.white.opacity(0.35), lineWidth: 1)
			}
			.shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 14)
	}
}

struct SoftFriendlyPrimaryButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline.weight(.bold))
			.foregroundStyle(Color.softAccentLabel)
			.frame(maxWidth: .infinity, minHeight: 58, maxHeight: 58)
			.background(Color.softAccent, in: .capsule)
			.shadow(color: Color.softAccent.opacity(configuration.isPressed ? 0.12 : 0.26), radius: configuration.isPressed ? 5 : 18, x: 0, y: configuration.isPressed ? 3 : 12)
			.scaleEffect(configuration.isPressed ? 0.97 : 1)
	}
}

extension View {
	func softFriendlyCard() -> some View {
		modifier(SoftFriendlyCardModifier())
	}
}
