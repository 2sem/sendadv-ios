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
    var canShow : Bool {
        get {
            // 리뷰 요청한 적이 없고, 메시지를 2번 이상 보낸 경우
            !LSDefaults.isReviewRequested && LSDefaults.MessageSentCount >= 2
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

