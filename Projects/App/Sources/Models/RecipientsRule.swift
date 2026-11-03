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
	/// Stable identity used by send history. Optional so existing stores migrate; assigned lazily.
	var uuid: UUID?

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

	/// Returns the stable id, assigning one on first use.
	@discardableResult
	func ensureUUID() -> UUID {
		if let uuid { return uuid }
		let newID = UUID()
		uuid = newID
		return newID
	}

	private static func nextOrder() -> Int {
		return 0
	}

	/// Creates default filters for the rule when none exist
    func createDefaultFilters() -> [RecipientsFilter] {
        let defaultFilters: [FilterTarget] = FilterTarget.allCases
        defaultFilters.forEach { [unowned self] target in
            let filter = RecipientsFilter(target: FilterTarget.organization)
            filters?.append(filter)
        }
        
        return filters ?? []
    }
}
