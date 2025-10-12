//
//  MediaViewSwiftUIView.swift
//  sendadv
//
//  Created by Assistant on 2025/10/12.
//

import SwiftUI
import GoogleMobileAds

struct MediaViewSwiftUIView: UIViewRepresentable {
    let mediaContent: MediaContent?

    init(mediaContent: MediaContent?) {
        self.mediaContent = mediaContent
    }

    final class ContainerView: UIView {
        let mediaView = MediaView()
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        private func setup() {
            backgroundColor = .clear
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            mediaView.contentMode = .scaleAspectFill
            mediaView.clipsToBounds = true
            addSubview(mediaView)
            NSLayoutConstraint.activate([
                mediaView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: trailingAnchor),
                mediaView.topAnchor.constraint(equalTo: topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    func makeUIView(context: Context) -> ContainerView {
        ContainerView()
    }

    func updateUIView(_ uiView: ContainerView, context: Context) {
        uiView.mediaView.mediaContent = mediaContent
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: ContainerView, context: Context) -> CGSize {
        CGSize(
            width: proposal.width ?? UIView.noIntrinsicMetric,
            height: proposal.height ?? UIView.noIntrinsicMetric
        )
    }
}
