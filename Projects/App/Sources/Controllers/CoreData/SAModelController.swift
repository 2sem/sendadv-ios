//
//  SAModelController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

class SAModelController : NSObject{
    struct EntityNames{
        static let SARecipientsRule = "SARecipientsRule";
        static let SAFilterRule = "SAFilterRule";
        static let SAMessage = "SAMessage";
    }
    
    // 마이그레이션을 위한 엔티티 속성 매핑
    struct EntityAttributes {
        struct SARecipientsRule {
            static let title = "title"
            static let enabled = "enabled"
            static let filters = "filters"
        }
        
        struct SAFilterRule {
            static let target = "target"
            static let includes = "includes"
            static let excludes = "excludes"
            static let all = "all"
            static let owner = "owner"
        }
    }
    
    static let FileName = "sendadv";
    
    internal static let dispatchGroupForInit = DispatchGroup();
    //    var SingletonQ = DispatchQueue(label: "SAModelController.Default");
    private static var _instance = SAModelController();
    static var Default : SAModelController{
        get{
            //let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(3);
            print("enter \(self) instance - \(self) - \(Thread.current)");
            let value = _instance;
            //            value.waitInit();
            print("wait \(self) instance - \(self) - \(Thread.current)");
            self.dispatchGroupForInit.wait();
            print("exit \(self) instance - \(self) - \(Thread.current)");
            
            return value;
        }
    }
    
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
            try? coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            
            return coordinator
        }()
        
        return context
    }
    
    var context : NSManagedObjectContext;
    internal override init(){
        //lock on
        //        objc_sync_enter(SAModelController.self)
        //        print("begin init SAModelController - \(SAModelController.self) - \(Thread.current)");
        //get path for model file
        //xcdatamodel => momd??
        guard let model_path = Bundle.main.url(forResource: SAModelController.FileName, withExtension: "momd") else{
            fatalError("Can not find Model File from Bundle");
        }
        
        //load model from model file
        guard let model = NSManagedObjectModel(contentsOf: model_path) else {
            fatalError("Can not load Model from File");
        }
        
        //create store controller??
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        //create data context
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
        //set store controller??
        self.context.persistentStoreCoordinator = psc;
        //lazy load??
        //        var queue = DispatchQueue(label: "SAModelController.init", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil);
        DispatchQueue.global(qos: .background).async(group: SAModelController.dispatchGroupForInit) {
            print("begin init SAModelController");
            //        DispatchQueue.main.async{
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
            
            //get path for app's url
            var docUrl = urls.last;
            //create path for data file
            docUrl?.appendPathComponent(SAModelController.FileName);
            docUrl?.appendPathExtension("sqlite");
            let storeUrl = docUrl;
            do {
                //set store type?
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]);
            } catch {
                
            }
            
            //lock off
            //            objc_sync_exit(SAModelController.self);
            //SAModelController.dispatchGroupForInit.leave();
            print("end init SAModelController");
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func waitInit(){
        //        dispatchPrecondition(condition: .notOnQueue(<#T##DispatchQueue#>))
        while self.context.persistentStoreCoordinator?.persistentStores.isEmpty ?? false{
            sleep(1);
        }
    }
    
    func reset(){
        self.context.reset();
    }
    
    var isSaved : Bool{
        return !self.context.hasChanges;
    }
    
    func saveChanges(){
        self.context.performAndWait {
            do{
                try self.context.save();
            } catch {
                fatalError("Save failed Error(\(error))");
            }
        }
    }
    
    /// MARK : support transaction
    func beginTransaction(transactionName name : String){
        if self.context.undoManager == nil {
            self.context.undoManager = UndoManager();
        }
        
        print("begin transaction. name[\(name)] context[\(self.context)]");
        self.context.undoManager?.beginUndoGrouping();
        self.context.undoManager?.setActionName(name);
    }
    
    func endTransaction(){
        print("end transaction. name[\(self.context.undoManager?.undoActionName ?? "")] context[\(self.context.description)]");
        if self.context.undoManager?.groupingLevel ?? 0 > 0{
            self.context.undoManager?.endUndoGrouping();
        }
    }
    
    func undo(){
        print("undo. name[\(self.context.undoManager?.undoActionName ?? "")] context[\(self.context.description)]");
        while self.context.undoManager?.groupingLevel ?? 0 > 1{
            self.context.undoManager?.endUndoGrouping();
        }
        self.context.undoManager?.undo();
    }
    
    func rollback(){
        print("rollback. context[\(self.context)]");
        self.context.rollback();
    }
}
