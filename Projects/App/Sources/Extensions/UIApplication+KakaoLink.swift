//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate

extension UIApplication{
    func shareByKakao(){
        let kakaoLink = Link();
        let kakaoContent = Content.init(title: UIApplication.shared.displayName ?? "", imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple118/v4/4e/e1/6d/4ee16d7c-64b1-f532-e95e-f335a5d9d4ea/mzl.hpndwfnb.png/150x150bb.jpg")!, imageWidth: 120, imageHeight: 120, description: "특정 회사/부서/직위로 SMS를 보내고 싶다면?", link: kakaoLink)
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "앱 스토어",
                                                              link: .init())])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
            
            UIApplication.shared.open(result.url)
            print("kakao warn[\(result.warningMsg?.debugDescription ?? "")] args[\(result.argumentMsg?.debugDescription ?? "")]")
        }
    }
}
