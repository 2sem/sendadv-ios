//
//  SAModelController+SAFilterRule.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension SAModelController{
    func loadFilterRules(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([SAFilterRule], NSError?) -> Void)? = nil) -> [SAFilterRule]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [SAFilterRule] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.SAFilterRule);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [SAFilterRule];
            print("fetch filters with predicate[\(predicate?.description ?? "")] count[\(values.count.description)]");
            completion?(values, nil);
        } catch{
            fatalError("Can not load Filters from DB");
        }
        
        return values;
    }
    
    func isExistFilterRule(_ target : String) -> Bool{
        let predicate = NSPredicate(format: "target == \"\(target)\"");
        return !self.loadFilterRules(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findFilterRules(_ target : String) -> [SAFilterRule]{
        let predicate = NSPredicate(format: "target == \"\(target)\"");
        return self.loadFilterRules(predicate: predicate, sortWays: nil);
    }
    
    func createFilterRule(target: String) -> SAFilterRule{
        let filter = NSEntityDescription.insertNewObject(forEntityName: EntityNames.SAFilterRule, into: self.context) as! SAFilterRule;
        
        filter.target = target;
        
        return filter;
    }
    
    func removeFilterRule(filter: SAFilterRule){
        self.context.delete(filter);
    }
    
    func refresh(filter: SAFilterRule){
        self.context.refresh(filter, mergeChanges: false);
    }
}
