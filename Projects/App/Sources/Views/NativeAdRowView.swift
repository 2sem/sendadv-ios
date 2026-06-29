//
//  NativeAdRowView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI

// A subview that displays a native ad row with given ad unit and index, using the provided interval to determine placement.
struct NativeAdRowView: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

	var body: some View {
		NativeAdSwiftUIView() { nativeAd in
			Group {
				if let ad = nativeAd {
					HStack(spacing: 18) {
						MediaViewSwiftUIView(mediaContent: ad.mediaContent)
							.frame(width: 72, height: 72)
							.clipShape(.rect(cornerRadius: 12, style: .continuous))
						VStack(alignment: .leading, spacing: 6) {
							Text(ad.headline ?? "")
								.font(.headline.weight(.bold))
								.foregroundStyle(Color.softPrimaryText)
								.lineLimit(2)
							if let body = ad.body {
								Text(body)
									.font(.subheadline)
									.foregroundStyle(Color.softSecondaryText)
									.lineLimit(2)
							}
							if let advertiser = ad.advertiser {
								Text(advertiser)
									.font(.caption)
									.foregroundStyle(Color.softSecondaryText.opacity(0.7))
							}
						}.task {
							await adManager.requestAppTrackingIfNeed()
                        }
						Spacer()
						if let cta = ad.callToAction {
							Button(cta) {}
								.font(.headline.weight(.bold))
								.foregroundStyle(.white)
								.padding(.horizontal, 18)
								.padding(.vertical, 12)
								.background(.black, in: .capsule)
						}
					}
				} else {
					HStack(spacing: 18) {
						Image("otherapp")
							.renderingMode(.original)
							.resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
							.frame(width: 72, height: 72)
							.clipShape(.rect(cornerRadius: 12, style: .continuous))
						VStack(alignment: .leading, spacing: 6) {
							Text("ads header".localized())
								.font(.headline.weight(.bold))
								.foregroundStyle(Color.softPrimaryText)
							Text("ads description".localized())
								.font(.subheadline)
								.foregroundStyle(Color.softSecondaryText)
								.lineLimit(3)
						}
						Spacer()
						Button("ads action".localized()) {
							//
						}
						.font(.headline.weight(.bold))
						.foregroundStyle(.white)
						.padding(.horizontal, 18)
						.padding(.vertical, 12)
						.background(.black, in: .capsule)
					}.onTapGesture {
                        guard let url = URL(string: "https://apps.apple.com/us/developer/young-jun-lee/id1225480114") else {
                            return
                        }
                        UIApplication.shared.open(url, options: [.universalLinksOnly : false], completionHandler: nil)
                    }
				}
			}
			.padding(16)
			.frame(minHeight: 118)
			.background(Color.dynamic(light: "#F0F0F7", dark: "#252331"), in: .rect(cornerRadius: 18, style: .continuous))
			// 'Ad' badge required by AdMob policy
			.overlay(alignment: .topLeading) {
				if nativeAd != nil {
					AdMarkView()
						.offset(x: 8, y: 8)
				}
			}
		}
	}
}

// MARK: - Ad Mark
private struct AdMarkView: View {
    private let text: String = "Ad" // Keep as "Ad" to satisfy policy; can be localized if needed
    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.yellow)
            )
            .accessibilityLabel("Advertisement")
    }
}
