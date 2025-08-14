//
//  RecipientsFilter+Init.swift
//  sendadv
//
//  Created by Cascade on 2025. 3. 14..
//

import CoreData
import SwiftData

@available(iOS 17.0, *)
extension RecipientsFilter {
    /// Creates a new RecipientsFilter from a Core Data SAFilterRule
    /// - Parameter filterRule: The Core Data SAFilterRule to create a RecipientsFilter from
    convenience init(from filterRule: SAFilterRule) {
        self.init(
            target: filterRule.target,
            includes: filterRule.includes,
            excludes: filterRule.excludes,
            all: filterRule.all
        )
    }
}
