//
//  RuleFilterScreenModel.swift
//  App
//
//  Created by 영준 이 on 8/19/25.
//

import SwiftData

@Observable
class RuleFilterScreenModel {
    var selectAll: Bool = false
    var availableItems: [String] = []
    var selectedItems: Set<String> = []
    
    private(set) var filter: RecipientsFilter
    private(set) var isSaved = false
    
    var title: String {
        FilterTarget(rawValue: filter.target ?? "")?.displayName.localized() ?? ""
    }
    
    init(filter: RecipientsFilter) {
        self.filter = filter
        
        // Load existing filter values
        self.selectAll = filter.all
        if !selectAll, let includes = filter.includes, !includes.isEmpty {
            self.selectedItems = Set(includes.components(separatedBy: ","))
        }
    }
    
    func loadItems() {
        // Load available items based on target
        switch FilterTarget(rawValue: filter.target ?? "") {
            case .job:
                availableItems = SAContactController.Default.loadJobTitles()
            case .department:
                availableItems = SAContactController.Default.loadDepartments()
            case .organization:
                availableItems = SAContactController.Default.loadOrganizations()
            default:
                availableItems = []
        }

        // If selectAll is true, populate selectedItems with all available items for display purposes
        if selectAll {
            selectedItems = Set(availableItems)
        }
    }

    func toggleSelectAll(_ newValue: Bool) {
        selectAll = newValue
        if newValue {
            // When "All" is turned on, select all available items
            selectedItems = Set(availableItems)
        } else {
            // When "All" is turned off manually, keep all items selected so user can deselect individually
            selectedItems = Set(availableItems)
        }
    }
    
    func toggleItem(_ item: String) {
        // If "All" is on, turn it off first and initialize selectedItems with all items except the one being toggled
        if selectAll {
            selectAll = false
            selectedItems = Set(availableItems)
            selectedItems.remove(item)
            return
        }

        // Normal toggle behavior
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
            // If all items are now selected, update selectAll
            if selectedItems.count == availableItems.count {
                selectAll = true
            }
        }
    }
    
    func save(context: ModelContext) {
        // Update filter values
        filter.all = selectAll
        filter.includes = selectAll ? nil : selectedItems.sorted().joined(separator: ",")
        
        // Save changes
        do {
//            try context.save()
        } catch {
            print("Failed to save filter:", error)
        }
    }
}
