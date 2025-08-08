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
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [RecipientsRule.self, FilterRule.self], inMemory: false)
		}
	}
}
