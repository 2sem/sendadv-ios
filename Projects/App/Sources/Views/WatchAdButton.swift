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
				Image(systemName: "gift")
					.font(.system(size: 20, weight: .medium))
					.frame(width: 44, height: 44)
					.foregroundColor(.accent)
			}
			.buttonStyle(.plain)
			.transition(.opacity.combined(with: .scale(scale: 0.8)))
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
