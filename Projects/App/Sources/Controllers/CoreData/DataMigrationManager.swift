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
            currentStep = "마이그레이션이 이미 완료되었습니다."
            return false
        }
        
        migrationStatus = .checking
        currentStep = "Core Data 데이터 확인 중..."
        
        // Core Data에 데이터가 있는지 확인
        guard await hasCoreData() else {
            migrationStatus = .completed
            currentStep = "마이그레이션이 필요하지 않습니다."
            isMigrationCompleted = true
            return false
        }
        
        migrationStatus = .migrating
        currentStep = "마이그레이션 시작..."
        
        do {
            try await performMigration()
            migrationStatus = .completed
            currentStep = "마이그레이션이 완료되었습니다."
            isMigrationCompleted = true
            return true
        } catch {
            migrationStatus = .failed(error)
            currentStep = "마이그레이션 실패: \(error.localizedDescription)"
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
        currentStep = "수신자 규칙 마이그레이션 중..."
        migrationProgress = 0.2
        
        let recipientsRules = try await fetchCoreDataRecipientsRules()
        
        // 2. FilterRule 마이그레이션
        currentStep = "필터 규칙 마이그레이션 중..."
        migrationProgress = 0.5
        
        let filterRules = try await fetchCoreDataFilterRules()
        
        // 3. Swift Data로 변환 및 저장
        currentStep = "Swift Data로 변환 중..."
        migrationProgress = 0.8
        
        try await convertAndSaveToSwiftData(recipientsRules: recipientsRules, filterRules: filterRules)
        
        migrationProgress = 1.0
    }
    
    private func fetchCoreDataRecipientsRules() async throws -> [NSManagedObject] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataController.context.perform {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: SAModelController.EntityNames.SARecipientsRule)
                
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
    
    private func convertAndSaveToSwiftData(recipientsRules: [NSManagedObject], filterRules: [NSManagedObject]) async throws {
        // ModelContainer 가져오기
        guard let modelContainer = try? ModelContainer(for: RecipientsRule.self, FilterRule.self) else {
            throw MigrationError.modelContainerCreationFailed
        }
        
        let context = modelContainer.mainContext
        
        // RecipientsRule 변환
        var swiftDataRecipientsRules: [RecipientsRule] = []
        for (index, coreDataRule) in recipientsRules.enumerated() {
            let swiftDataRule = RecipientsRule(
                title: coreDataRule.value(forKey: SAModelController.EntityAttributes.SARecipientsRule.title) as? String,
                enabled: coreDataRule.value(forKey: SAModelController.EntityAttributes.SARecipientsRule.enabled) as? Bool ?? true,
                order: index
            )
            
            swiftDataRecipientsRules.append(swiftDataRule)
            context.insert(swiftDataRule)
        }
        
        // FilterRule 변환 및 관계 설정
        for coreDataFilter in filterRules {
            let swiftDataFilter = FilterRule(
                target: coreDataFilter.value(forKey: SAModelController.EntityAttributes.SAFilterRule.target) as? String,
                includes: coreDataFilter.value(forKey: SAModelController.EntityAttributes.SAFilterRule.includes) as? String,
                excludes: coreDataFilter.value(forKey: SAModelController.EntityAttributes.SAFilterRule.excludes) as? String,
                all: coreDataFilter.value(forKey: SAModelController.EntityAttributes.SAFilterRule.all) as? Bool ?? false
            )
            
            // 관계 설정
            if let owner = coreDataFilter.value(forKey: SAModelController.EntityAttributes.SAFilterRule.owner) as? NSManagedObject,
               let ownerIndex = recipientsRules.firstIndex(of: owner),
               ownerIndex < swiftDataRecipientsRules.count {
                swiftDataFilter.owner = swiftDataRecipientsRules[ownerIndex]
                swiftDataRecipientsRules[ownerIndex].filters?.append(swiftDataFilter)
            }
            
            context.insert(swiftDataFilter)
        }
        
        // 저장
        try context.save()
        
        // 마이그레이션 완료 후 Core Data 파일 정리
        await cleanupCoreDataFiles()
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
            return "Swift Data 모델 컨테이너 생성에 실패했습니다."
        }
    }
}
