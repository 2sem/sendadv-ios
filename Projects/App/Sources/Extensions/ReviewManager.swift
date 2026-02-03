//
//  ReviewManager.swift
//  wherewego
//
//  Created by 영준 이 on 2017. 5. 29..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import LSExtensions
import StoreKit

class ReviewManager : ObservableObject {
    /// 발송 5회 성공 시에만 리뷰 요청 가능 (이후 노출하지 않음)
    var canShow : Bool {
        get {
            !LSDefaults.isReviewRequested && LSDefaults.MessageSentCount == 5
        }
    }

    func show(_ force : Bool = false) {
        guard self.canShow || force else {
            return
        }

        Task{ [unowned self] in
            await self._show()
        }
    }

    @MainActor internal func _show() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        AppStore.requestReview(in: scene)

        // 리뷰 요청 기록
        LSDefaults.updateReviewRequestDate()
    }
}

