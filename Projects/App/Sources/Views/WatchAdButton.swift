//
//  WatchAdButton.swift
//  sendadv
//
//  Created by 영준 이 on 3/23/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct WatchAdButton: View {
	@EnvironmentObject private var adManager: SwiftUIAdManager
	@Binding var isAdFree: Bool
	var onAdFreeActivated: (() -> Void)?

	@State private var showConfirmation = false

	var body: some View {
		if !isAdFree {
			Button(action: {
				showConfirmation = true
			}) {
				ZStack {
					Circle()
						.fill(Color.softSurfaceElevated)
						.overlay {
							Circle()
								.stroke(Color.softDivider.opacity(0.75), lineWidth: 1)
						}
						.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
					Image(systemName: "gift.fill")
						.font(.system(size: 18, weight: .medium))
						.foregroundStyle(Color.softAccent)
				}
				.frame(width: 64, height: 64)
				.overlay(alignment: .topTrailing) {
					Text("1h")
						.font(.caption2.weight(.bold))
						.foregroundStyle(.white)
						.padding(.horizontal, 7)
						.padding(.vertical, 4)
						.background(Color.dynamic(light: "#F2855F", dark: "#FF9D78"), in: .capsule)
						.offset(x: 7, y: -6)
				}
			}
			.buttonStyle(.plain)
			.accessibilityLabel("watch.ad.accessibility.label".localized())
			.accessibilityHint("watch.ad.accessibility.hint".localized())
			.transition(.opacity.combined(with: .scale(scale: 0.85)))
			.confirmationDialog(
				"watch.ad.title".localized(),
				isPresented: $showConfirmation,
				titleVisibility: .visible
			) {
				Button("watch.ad.action".localized()) {
					Task { @MainActor in
						adManager.showRewarded { rewarded in
							if rewarded {
								LSDefaults.activateAdFree()
								withAnimation(.easeInOut(duration: 0.25)) {
									isAdFree = true
								}
								onAdFreeActivated?()
							}
						}
					}
				}
				Button(role: .cancel) {
				} label: { Text("Cancel".localized()) }
			} message: {
				Text("watch.ad.message".localized())
			}
		}
	}
}
