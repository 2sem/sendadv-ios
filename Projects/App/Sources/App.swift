//
//  App.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import Firebase
import StoreKit
import GADManager

@main
struct SendadvApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@State private var isSplashDone = false

	var body: some Scene {
		WindowGroup {
			ZStack {
				// 메인 화면 (루트)
				NavigationStack {
					RecipientRuleListScreen()
				}
				.modelContainer(for: [RecipientsRule.self, RecipientsFilter.self], inMemory: false)
//				.opacity(isSplashDone ? 0 : 1)
				
				// 스플래시 오버레이
				if !isSplashDone {
					SplashScreen(isDone: $isSplashDone)
						.transition(.opacity)
				}
			}
		}
	}
}

