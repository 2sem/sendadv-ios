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
    @State private var showSplash = true

	var body: some Scene {
		WindowGroup {
            ZStack {
                ContentView()
                    .modelContainer(for: [RecipientsRule.self, FilterRule.self], inMemory: false)
                    .opacity(showSplash ? 0 : 1)
                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
		}
	}
}

