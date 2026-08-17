//
//  SAContactController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 31..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import ContactsUI

class SAContactController : NSObject{
    private(set) static var Default = SAContactController();
    let contactStore = CNContactStore();
    //from List of mobile phone number series by country
    
    func loadAllContacts(_ keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactNameSuffixKey as CNKeyDescriptor, CNContactDepartmentNameKey as CNKeyDescriptor, CNContactJobTitleKey as CNKeyDescriptor, CNContactOrganizationNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]) throws -> [CNContact]{
        var values : [CNContact] = [];
        let containerID = self.contactStore.defaultContainerIdentifier();
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerID);
        
        CNContact.localizedString(forKey: CNLabelPhoneNumberMain);
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone);
        CNContact.localizedString(forKey: CNLabelPhoneNumberMobile);
        
        values = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys);

        return values;
    }

    /// Async wrapper around `loadAllContacts(_:)` that runs the (blocking) address book fetch
    /// off the main actor, so `@MainActor`-isolated callers (e.g. `RuleDetailScreenModel`) don't
    /// block the UI thread while `CNContactStore` walks the default container.
    func loadAllContactsAsync(_ keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactNameSuffixKey as CNKeyDescriptor, CNContactDepartmentNameKey as CNKeyDescriptor, CNContactJobTitleKey as CNKeyDescriptor, CNContactOrganizationNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]) async throws -> [CNContact]{
        try await Task.detached(priority: .userInitiated) { [self] in
            try self.loadAllContacts(keys);
        }.value;
    }

    /// Requests the user's permission to access Contacts. Intended for the `.notDetermined`
    /// case - calling this once authorization is already decided just re-reports that decision.
    /// Returns `false` (rather than throwing) on any failure, since callers only care about the
    /// granted/denied outcome.
    func requestContactsAccess() async -> Bool {
        (try? await contactStore.requestAccess(for: .contacts)) ?? false;
    }

    func loadContacts(rules : [RecipientsRule]) -> [String]?{
        var values : [String]! = []
        // Membership-only accumulator for dedup - `values` stays the ordered, insertion-order
        // result this method has always returned (its caller, `RecipientListScreenModel
        // .phoneNumbers`, depends on that order). The `Set` just makes the per-contact
        // "already used?" check O(1) instead of an O(n) array scan.
        var usedNumbers: Set<String> = [];
        let rules = rules.filter { (rule) -> Bool in
            return rule.enabled;
        }

        do{
            let contacts = try self.loadAllContacts();

            NSLog("load contacts. count[\(contacts.count)]");
            for contact in contacts{
                guard let mobile = self.firstUsableMobileNumber(for: contact, excluding: usedNumbers) else{
                    continue;
                }

                //filter by rule
                var needToAdd = true;
                for rule in rules{
                    needToAdd = self.isMatchedContact(contact: contact, rule: rule);
                    if needToAdd{
                        break;
                    }
                }

                guard needToAdd else{
                    continue;
                }

                usedNumbers.insert(mobile);
                values.append(mobile);
            }

            //            self.generate(contacts);

        }catch(let error){
            NSLog("load contacts error[\(error)]");
            values = nil;
        }

        return values;
    }

    /// Counts sendable phone numbers (one deduped mobile per contact) that match the given
    /// filter conditions, regardless of any rule's `enabled` flag.
    ///
    /// Used by the recipient-count preview on `RuleDetailScreen` while a rule is being edited,
    /// including rules that are currently disabled. Does not fetch contacts itself — pass in a
    /// previously-loaded `[CNContact]` snapshot so repeated recounts stay in memory.
    func recipientCount(contacts: [CNContact], filters: [RecipientsFilter]) -> Int{
        var usedNumbers: Set<String> = [];
        var count = 0;

        for contact in contacts{
            guard let mobile = self.firstUsableMobileNumber(for: contact, excluding: usedNumbers) else{
                continue;
            }

            guard self.isMatchedContact(contact: contact, filters: filters) else{
                continue;
            }

            usedNumbers.insert(mobile);
            count += 1;
        }

        return count;
    }

    /// Returns the first mobile number on `contact` that isn't already present in `usedNumbers`,
    /// mirroring the dedup behavior `loadContacts(rules:)` has always used. `usedNumbers` is a
    /// `Set` so this membership check is O(1) per phone number instead of an O(n) array scan -
    /// this runs per-contact on every recount, so an array scan here made the whole pass O(n^2).
    private func firstUsableMobileNumber(for contact: CNContact, excluding usedNumbers: Set<String>) -> String?{
        for phone in contact.phoneNumbers{
            let number = phone.value.stringValue;
            guard SAMobileController.Default.isMobile(phone: phone) else{
                continue;
            }

            if !usedNumbers.contains(number){
                return number;
            }
        }

        return nil;
    }
    
    func loadJobTitles() -> [String]{
        return self.distinctForKey(CNContactJobTitleKey as CNKeyDescriptor);
    }
    
    func loadDepartments() -> [String]{
        return self.distinctForKey(CNContactDepartmentNameKey as CNKeyDescriptor);
    }
    
    func loadOrganizations() -> [String]{
        return self.distinctForKey(CNContactOrganizationNameKey as CNKeyDescriptor);
    }
    
    func distinctForKey(_ key: CNKeyDescriptor) -> [String]{
        var values : [String : String] = [:];
        do{
            let contacts = try self.loadAllContacts([key]);
            for contact in contacts{
                var text = "";
                if key.isEqual(CNContactJobTitleKey) {
                    text = contact.jobTitle;
                }else if key.isEqual(CNContactDepartmentNameKey) {
                    text = contact.departmentName;
                }else if key.isEqual(CNContactOrganizationNameKey) {
                    text = contact.organizationName;
                }
                
                guard !text.isEmpty else{
                    continue;
                }
                
                values[text] = "";
            }
        }catch{}
        
        return Array(values.keys);
    }

    func isMobileNumber(number: String, prefixes: [String]) -> Bool{
        var value = false;
        
        for prefix in prefixes{
            if number.hasPrefix(prefix){
                value = true;
                break;
            }
        }
        
        return value;
    }
    
    func isMatchedContact(contact : CNContact, rule : RecipientsRule) -> Bool{
        return self.isMatchedContact(contact: contact, filters: rule.filters ?? []);
    }

    /// Matches `contact` against a raw set of filter conditions, independent of any owning
    /// rule's `enabled` flag. Shared by `isMatchedContact(contact:rule:)` and `recipientCount`.
    func isMatchedContact(contact : CNContact, filters : [RecipientsFilter]) -> Bool{
        guard !filters.isEmpty else{
            return true;
        }
        //name, nickname, jot title, department, company
        for filter in filters{
            guard self.isMatchedContact(contact: contact, filter: filter) else{
                return false;
            }
        }

        return true;
    }
    
    class FilterTargetNames{
        static let Name = "name";
        static let Nickname = "nickname";
        static let Job = "job";
        static let Department = "dept";
        static let Organization = "org";
    }
    
    func isMatchedContact(contact : CNContact, filter : RecipientsFilter) -> Bool{
        var value = false;
        //name, nickname, jot title, department, company
        guard !filter.all else {
            return true
        }
        
        switch filter.target ?? ""{
            case FilterTargetNames.Name:
                value = self.isMatchedText(text: contact.fullName ?? "", filter: filter);
                break;
            case FilterTargetNames.Nickname:
                value = self.isMatchedText(text: contact.nickname, filter: filter);
                break;
            case FilterTargetNames.Job:
                value = self.isMatchedText(text: contact.jobTitle, filter: filter);
                break;
            case FilterTargetNames.Department:
                value = self.isMatchedText(text: contact.departmentName, filter: filter);
                break;
            case FilterTargetNames.Organization:
                value = self.isMatchedText(text: contact.organizationName, filter: filter);
                break;
            default:
                break;
        }
        
        return value;
    }
    
    func isMatchedText(text: String, filter : RecipientsFilter) -> Bool{
        var value = true;
        
        guard !filter.all else{
            return value;
        }
        
        let excludes = (filter.excludes ?? "").components(separatedBy: ",");
        
        for exclude in excludes{
            if text.contains(exclude){
                value = false;
                break;
            }
        }
        
        guard value else{
            return value;
        }
        
        value = false;
        let includes = (filter.includes ?? "").components(separatedBy: ",");
        guard !includes.isEmpty else{
            return !value;
        }
        
        guard !text.isEmpty else{
            return value;
        }
        
        for include in includes{
            
            if text == include{
            //contains
//            if text.contains(include){
                value = true;
                break;
            }
        }
        
        return value;
    }
}
