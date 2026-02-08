//
//  RuleRepository.swift
//  App
//
//  Created by 영준 이 on 8/6/25.
//

import SwiftData
import CoreData

protocol RuleRepository {
    
}

class SARuleRepository : RuleRepository {
    static var shared = SARuleRepository()
    
    static var contextForPreview : NSManagedObjectContext {
        guard let model_path = Bundle.main.url(forResource: SAModelController.FileName, withExtension: "momd") else{
            fatalError("Can not find Model File from Bundle");
        }
        
        //load model from model file
        guard let model = NSManagedObjectModel(contentsOf: model_path) else {
            fatalError("Can not load Model from File");
        }
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            _ = try? coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

            return coordinator
        }()
        
        return context
    }
}
