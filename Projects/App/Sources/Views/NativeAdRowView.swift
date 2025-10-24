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
    
    let index: Int
    let interval: Int

    var body: some View {
        if index % interval == 0 {
            NativeAdSwiftUIView() { nativeAd in
                Group {
                    if let ad = nativeAd {
                        HStack(spacing: 12) {
                            MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 6) {
                                Text(ad.headline ?? "")
                                    .font(.headline)
                                if let body = ad.body {
                                    Text(body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if let advertiser = ad.advertiser {
                                    Text(advertiser)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }.task {
                                await adManager.requestAppTrackingIfNeed()
                            }
                            Spacer()
                            if let cta = ad.callToAction {
                                Button(cta) {}
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image("otherapp")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ads header".localized())
                                    .font(.headline)
                                Text("ads description".localized())
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("ads action".localized()) {
                                //
                            }
                            .buttonStyle(.borderedProminent)
                        }.onTapGesture {
                            guard let url = URL(string: "https://apps.apple.com/us/developer/young-jun-lee/id1225480114") else {
                                return
                            }
                            UIApplication.shared.open(url, options: [.universalLinksOnly : false], completionHandler: nil)
                        }
                    }
                }
                .frame(height: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                // 'Ad' badge required by AdMob policy
                .overlay(alignment: .topLeading) {
                    if nativeAd != nil {
                        AdMarkView()
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
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
