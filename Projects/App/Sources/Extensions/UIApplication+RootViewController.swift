//
//  UIApplication+RootViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2026. 2. 5..
//  Copyright © 2026 leesam. All rights reserved.
//

import UIKit

extension UIApplication {
	/// foregroundActive 씨너에서 키 윈도우의 rootViewController를 반환합니다.
	/// UIWindowScene을 직접 사용하는 보일러플레이트를 제거하기 위한 편의 속성입니다.
	var topRootViewController: UIViewController? {
		(connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)
			?.windows
			.first(where: { $0.isKeyWindow })
			?.rootViewController
	}
}
