//
//  FilterRule.swift
//  App
//
//  Created by 영준 이 on 8/6/25.
//

import SwiftData

@Model
final class RecipientsFilter: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
    var target: String?
    var includes: String?
    var excludes: String?
    var all: Bool
    var owner: RecipientsRule?
    
    init(target: String? = nil, includes: String? = nil, excludes: String? = nil, all: Bool = false) {
        self.target = target
        self.includes = includes
        self.excludes = excludes
        self.all = all
    }
}
