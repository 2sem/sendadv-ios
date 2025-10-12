//
//  RecipientsViewModel.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import SwiftData

protocol RecipientListScreenModel {
    var phoneNumbers: [String] { get set }
    
    func toggleRule(_ rule: RecipientsRule, isEnabled: Bool)
    func deleteRule(_ rule: RecipientsRule, modelContext: ModelContext)
    func phoneNumbers(for rules: [RecipientsRule], allowAll: Bool) async throws(SendError) -> [String]
}

// MARK: - ViewModel
@Observable
class SARecipientListScreenModel: RecipientListScreenModel {
    
    var phoneNumbers: [String] = []
    
    func toggleRule(_ rule: RecipientsRule, isEnabled: Bool) {
        rule.enabled = isEnabled
    }
    
    func deleteRule(_ rule: RecipientsRule, modelContext: ModelContext) {
        modelContext.delete(rule)
        try? modelContext.save()
    }
    
    func remove(_ rules: [RecipientsRule]) {
        // This method is a no-op since deletion is handled by SwiftUI's @ModelContext
        // The actual deletion will be handled by the view's onDelete modifier
    }
    
    func phoneNumbers(for rules: [RecipientsRule], allowAll: Bool) async throws(SendError) -> [String] {
        // 활성화된 규칙이 있는지 확인
        let enabledRules = rules.filter { $0.enabled }
        
        if !allowAll && enabledRules.isEmpty {
            throw .noRulesEnabled
        }
        
        // 연락처에서 전화번호 가져오기
        let phones = SAContactController.Default.loadContacts(rules: enabledRules)
        
        guard let phones = phones else {
            throw .permissionDenied
        }
        
        guard !phones.isEmpty else {
            throw .noContacts
        }
        
        return phones
    }
    
    func createRule(modelContext: ModelContext) -> RecipientsRule? {
        let newRule = RecipientsRule(title: "New Rule".localized(), enabled: true)
        
        do {
            
            modelContext.insert(newRule)
//            try modelContext.save()
        } catch {
            return nil
        }
        
        return newRule
    }
}

enum SendError: Error {
	case noRulesEnabled
	case noContacts
	case permissionDenied
} 
