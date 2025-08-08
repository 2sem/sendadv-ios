//
//  ContentView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	var body: some View {
		ZStack {
			Color.background
				.ignoresSafeArea()
				
			NavigationStack {
                SARecipientRuleListScreen()
			}
        }
	}
}

#Preview {
    ContentView()
        .modelContainer(for: [RecipientsRule.self, FilterRule.self], inMemory: true)
}
