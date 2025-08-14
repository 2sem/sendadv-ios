//
//  SARecipientsRule.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import Foundation
import SwiftData

@Model
final class RecipientsRule: Identifiable {
	var id: PersistentIdentifier { persistentModelID }
	var title: String?
	var enabled: Bool
    @Relationship(deleteRule: .cascade) var filters: [RecipientsFilter]?
	@Attribute var order: Int

	init(title: String? = nil, enabled: Bool = true, order: Int? = nil) {
		self.title = title
		self.enabled = enabled
		self.filters = []
		if let order = order {
			self.order = order
		} else {
			self.order = Self.nextOrder()
		}
	}

	private static func nextOrder() -> Int {
		return 0
	}
}
