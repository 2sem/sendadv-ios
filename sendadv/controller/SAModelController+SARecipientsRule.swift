//
//  SAModelController+SARecipientsRule.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension SAModelController{
    func loadRecipientsRules(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([SARecipientsRule], NSError?) -> Void)? = nil) -> [SARecipientsRule]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [SARecipientsRule] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.SARecipientsRule);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [SARecipientsRule];
            print("fetch rules with predicate[\(predicate?.description ?? "")] count[\(values.count.description)]");
            completion?(values, nil);
        } catch{
            fatalError("Can not load Recipients from DB");
        }
        
        return values;
    }
    
    func isExistRecipientsRule(_ title : String) -> Bool{
        let predicate = NSPredicate(format: "title == \"\(title)\"");
        return !self.loadRecipientsRules(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findRecipientsRules(_ title : String) -> [SARecipientsRule]{
        let predicate = NSPredicate(format: "title == \"\(title)\"");
        return self.loadRecipientsRules(predicate: predicate, sortWays: nil);
    }
    
    func createRecipientsRule(title: String) -> SARecipientsRule{
        let rule = NSEntityDescription.insertNewObject(forEntityName: EntityNames.SARecipientsRule, into: self.context) as! SARecipientsRule;
        
        rule.title = title;
        rule.enabled = true;
        
        return rule;
    }
    
    func removeRecipientsRule(rule: SARecipientsRule){
        self.context.delete(rule);
    }
    
    func refresh(rule: SARecipientsRule){
        self.context.refresh(rule, mergeChanges: false);
    }
}
