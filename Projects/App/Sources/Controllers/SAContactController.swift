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
    
    func loadContacts(rules : [SARecipientsRule]) -> [String]?{
        var values : [String]! = []
        let rules = rules.filter { (rule) -> Bool in
            return rule.enabled;
        }
        
        do{
            let contacts = try self.loadAllContacts();
            
            NSLog("load contacts. count[\(contacts.count)]");
            for contact in contacts{
                var mobile = "";
                
                //get only one mobile number for a contact
                for phone in contact.phoneNumbers{
                    let number = phone.value.stringValue;
                    guard SAMobileController.Default.isMobile(phone: phone) else{
//                    guard self.isMobileNumber(number: number, prefixes: mobilePrefixesForKor) else{
                        continue;
                    }
                    
                    if !values.contains(number){
                        mobile = number;
                        break;
                    }
                }
                
                if mobile.isEmpty{
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
                
                values.append(mobile);
            }
            
            //            self.generate(contacts);
            
        }catch(let error){
            NSLog("load contacts error[\(error)]");
            values = nil;
        }
        
        return values;
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
    
    func isMatchedContact(contact : CNContact, rule : SARecipientsRule) -> Bool{
        var value = true;
        let filters = (rule.filters?.allObjects as? [SAFilterRule]) ?? [];

        guard !filters.isEmpty else{
            return value;
        }
        //name, nickname, jot title, department, company
        for filter in filters{
            value = value && self.isMatchedContact(contact: contact, filter: filter);
            if !value {
                break;
            }
        }
        
        return value;
    }
    
    class FilterTargetNames{
        static let Name = "name";
        static let Nickname = "nickname";
        static let Job = "job";
        static let Department = "dept";
        static let Organization = "org";
    }
    func isMatchedContact(contact : CNContact, filter : SAFilterRule) -> Bool{
        var value = false;
        //name, nickname, jot title, department, company
    
        switch filter.target ?? ""{
            case FilterTargetNames.Name:
                value = self.isMatchedText(text: contact.fullName ?? "", filter: filter);
                break;
            case FilterTargetNames.Nickname:
                value = self.isMatchedText(text: contact.nickname, filter: filter);
                break;
            case FilterTargetNames.Job:
                value = self.isMatchedText(text: contact.jobTitle, filter: filter);
                print("filter contract. name[\(contact.fullName ?? "")] job[\(contact.jobTitle)] => \(value)");
                break;
            case FilterTargetNames.Department:
                value = self.isMatchedText(text: contact.departmentName, filter: filter);
                print("filter contract. name[\(contact.fullName ?? "")] dept[\(contact.departmentName)] => \(value)");
                break;
            case FilterTargetNames.Organization:
                value = self.isMatchedText(text: contact.organizationName, filter: filter);
                print("filter contract. name[\(contact.fullName ?? "")] org[\(contact.organizationName)] => \(value)");
                break;
            default:
                break;
        }
        
        return value;
    }
    
    func isMatchedText(text: String, filter : SAFilterRule) -> Bool{
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
