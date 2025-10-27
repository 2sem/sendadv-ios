//
//  RecipientFilterListScreenModel.swift
//  App
//
//  Created by 영준 이 on 8/6/25.
//

import SwiftUI
import SwiftData

@Observable
class RuleDetailScreenModel {
	var rule: RecipientsRule?
	var title: String = ""
    var isSaved: Bool = false
	
	init(rule: RecipientsRule?) {
		self.rule = rule
        self.title = rule?.title ?? ""
	}
	
    func save(using context: ModelContext) {
        rule?.title = title
        try? context.save()
        isSaved = true
	}
    
    func rollback(withUndoManager undoManager: UndoManager) {
        undoManager.undo()
        while undoManager.canUndo {
            undoManager.undo()
//        undoManager.endUndoGrouping()
//        undoManager.undoNestedGroup()
        }
        print("Rule Detail is be rollbacked. is Main Thread: \(Thread.isMainThread)")
    }
	
	func getFilterText(for target: String) -> String {
		guard let rule = rule,
			  let filters = rule.filters else {
			return "All".localized()
		}
		
		let filter = filters.first { $0.target == target }
		
		if filter == nil || filter?.all == true {
			return "All".localized()
		}
		
		guard let includes = filter?.includes else {
			return "All".localized()
		}
		
		let keywords = includes.components(separatedBy: ",").filter { !$0.isEmpty }
		
		if keywords.isEmpty {
			return "All".localized()
		}
		
		if keywords.count == 1 {
			return keywords[0]
		}
		
		return "\(keywords[0]) and \(keywords.count - 1) others".localized()
	}
	
	func getJobFilterText() -> String {
		return getFilterText(for: "job")
	}
	
	func getDepartmentFilterText() -> String {
		return getFilterText(for: "dept")
	}
	
	func getOrganizationFilterText() -> String {
		return getFilterText(for: "org")
	}
	
	func getOrCreateFilter(for target: String) -> RecipientsFilter {
		guard let rule = rule else {
            let filter = RecipientsFilter(target: .init(rawValue: target), includes: nil, excludes: nil, all: true)
			return filter
		}
		
		// Try to find existing filter
		if let existingFilter = rule.filters?.first(where: { $0.target == target }) {
			return existingFilter
		}
		
		// Create new filter if not found
		let newFilter = RecipientsFilter(target: .init(rawValue: target), includes: nil, excludes: nil, all: true)
		rule.filters?.append(newFilter)
		return newFilter
	}
}
