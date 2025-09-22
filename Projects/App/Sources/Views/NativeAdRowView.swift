//
//  NativeAdRowView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI

// A subview that displays a native ad row with given ad unit and index, using the provided interval to determine placement.
struct NativeAdRowView: View {
    let nativeAdUnit: String
    let index: Int
    let interval: Int

    var body: some View {
        if index % interval == 0 {
            NativeAdSwiftUIView(adUnitId: nativeAdUnit) { nativeAd in
                Group {
                    if let ad = nativeAd {
                        HStack(spacing: 12) {
                            if let icon = ad.icon?.image {
                                Image(uiImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
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
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
            }
        }
    }
}
