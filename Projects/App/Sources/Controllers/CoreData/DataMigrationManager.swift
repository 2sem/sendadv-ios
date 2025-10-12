//
//  DataMigrationManager.swift
//  sendadv
//
//  Created by 영준 이 on 8/6/25.
//  Copyright 2025년 leesam. All rights reserved.
//

import Foundation
import CoreData
import SwiftData

@MainActor
class DataMigrationManager: ObservableObject {
    @Published var migrationProgress: Double = 0.0
    @Published var migrationStatus: MigrationStatus = .idle
    @Published var currentStep: String = ""
    
    enum MigrationStatus {
        case idle
        case checking
        case migrating
        case completed
        case failed(Error)
    }
    
    private let coreDataController = SAModelController.Default
    private let userDefaults = UserDefaults.standard
    private let migrationCompletedKey = "DataMigrationCompleted"
    
    var isMigrationCompleted: Bool {
        get { userDefaults.bool(forKey: migrationCompletedKey) }
        set { userDefaults.set(newValue, forKey: migrationCompletedKey) }
    }
    
    func checkAndMigrateIfNeeded() async -> Bool {
        // 이미 마이그레이션이 완료된 경우
        if isMigrationCompleted {
            migrationStatus = .completed
            currentStep = "Migration already completed.".localized()
            return false
        }
        
        migrationStatus = .checking
        currentStep = "Checking Core Data...".localized()
        
        // Core Data에 데이터가 있는지 확인
        guard await hasCoreData() else {
            migrationStatus = .completed
            currentStep = "No migration needed.".localized()
            isMigrationCompleted = true
            return false
        }
        
        migrationStatus = .migrating
        currentStep = "Starting migration...".localized()
        
        do {
            try await performMigration()
            migrationStatus = .completed
            currentStep = "Migration completed.".localized()
            isMigrationCompleted = true
            return true
        } catch {
            migrationStatus = .failed(error)
            currentStep = String(format: "Migration failed: %@".localized(), error.localizedDescription)
            return false
        }
    }
    
    private func hasCoreData() async -> Bool {
        return await withCheckedContinuation { continuation in
            coreDataController.context.perform {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: SAModelController.EntityNames.SARecipientsRule)
                fetchRequest.fetchLimit = 1
                
                do {
                    let count = try self.coreDataController.context.count(for: fetchRequest)
                    continuation.resume(returning: count > 0)
                } catch {
                    print("Core Data 확인 중 오류: \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private func performMigration() async throws {
        // 1. RecipientsRule 마이그레이션
        currentStep = "Migrating recipients rules...".localized()
        migrationProgress = 0.2
        
        let recipientsRules = try await fetchCoreDataRecipientsRules()
        
        // 2. FilterRule 마이그레이션
        currentStep = "Migrating filter rules...".localized()
        migrationProgress = 0.5
        
//        let filterRules = try await fetchCoreDataFilterRules()
        
        // 3. Swift Data로 변환 및 저장
        currentStep = "Converting to SwiftData...".localized()
        migrationProgress = 0.8
        
        try await convertAndSaveToSwiftData(recipientsRules: recipientsRules)
        
        migrationProgress = 1.0
    }
    
    private func fetchCoreDataRecipientsRules() async throws -> [SARecipientsRule] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataController.context.perform {
                let fetchRequest: NSFetchRequest<SARecipientsRule> = NSFetchRequest(entityName: SAModelController.EntityNames.SARecipientsRule)
                
                do {
                    let rules = try self.coreDataController.context.fetch(fetchRequest)
                    
                    continuation.resume(returning: rules)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchCoreDataFilterRules() async throws -> [NSManagedObject] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataController.context.perform {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: SAModelController.EntityNames.SAFilterRule)
                
                do {
                    let rules = try self.coreDataController.context.fetch(fetchRequest)
                    continuation.resume(returning: rules)
                } catch  {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func convertAndSaveToSwiftData(recipientsRules: [SARecipientsRule]) async throws {
        // Update progress
        await MainActor.run {
            currentStep = "Converting recipients data...".localized()
            migrationProgress = 0.5
        }
        
        // ModelContainer 가져오기
        guard let modelContainer = try? ModelContainer(for: RecipientsRule.self, RecipientsFilter.self) else {
            throw MigrationError.modelContainerCreationFailed
        }
        
        let context = modelContainer.mainContext
        let modelController = SAModelController()
        let totalRules = recipientsRules.count
        
        // RecipientsRule 변환
        var swiftDataRecipientsRules: [RecipientsRule] = []
        
        for (index, coreDataRule) in recipientsRules.enumerated() {
            // Update progress for each rule
            let progress = 0.5 + (Double(index) / Double(totalRules * 2))
            await MainActor.run {
                migrationProgress = min(progress, 0.9) // Cap at 90% to leave room for cleanup
            }
            
            // Create new RecipientsRule using the new initializer
            let swiftDataRule = RecipientsRule(from: coreDataRule)
            
            // Migrate filters for this rule
            if let coreDataFilters = coreDataRule.filters as? Set<SAFilterRule> {
                for coreDataFilter in coreDataFilters {
                    let filter = RecipientsFilter(from: coreDataFilter)
                    swiftDataRule.filters?.append(filter)
                    context.insert(filter)
                }
            }

            // If the new rule doesn't have any filters, create them
            if swiftDataRule.filters?.isEmpty ?? true {
                swiftDataRule.createDefaultFilters().forEach { filter in
                    context.insert(filter)
                }
            }
            
            swiftDataRecipientsRules.append(swiftDataRule)
            context.insert(swiftDataRule)
            
            // Periodically save to prevent memory issues with large datasets
            if index % 10 == 0 {
                try? context.save()
            }
        }
        
        // Final save
        try context.save()
        
        // Update progress before cleanup
        await MainActor.run {
            currentStep = "Finalizing migration...".localized()
            migrationProgress = 0.95
        }
        
        // Clean up Core Data files
        await cleanupCoreDataFiles()
        
        // Mark migration as complete
        await MainActor.run {
            migrationProgress = 1.0
        }
    }
    
    private func cleanupCoreDataFiles() async {
        // Core Data SQLite 파일 삭제
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let docUrl = urls.last {
            let sqliteURL = docUrl.appendingPathComponent(SAModelController.FileName).appendingPathExtension("sqlite")
            let sqliteShmURL = docUrl.appendingPathComponent(SAModelController.FileName).appendingPathExtension("sqlite-shm")
            let sqliteWalURL = docUrl.appendingPathComponent(SAModelController.FileName).appendingPathExtension("sqlite-wal")
            
            try? FileManager.default.removeItem(at: sqliteURL)
            try? FileManager.default.removeItem(at: sqliteShmURL)
            try? FileManager.default.removeItem(at: sqliteWalURL)
            
            print("Core Data 파일 정리 완료")
        }
    }
}

enum MigrationError: LocalizedError {
    case modelContainerCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .modelContainerCreationFailed:
            return "Failed to create SwiftData model container.".localized()
        }
    }
}
