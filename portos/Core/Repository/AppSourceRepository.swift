//
//  AppSourceRepository.swift
//  portos
//
//  Created by Medhiko Biraja on 18/08/25.
//

import Foundation
import SwiftData

class AppSourceRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAppSource(appId: UUID) throws -> AppSource? {
        var descriptor = FetchDescriptor<AppSource>(
            predicate: #Predicate{ $0.id == appId }
        )
        
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func getAllAppSource() throws -> [AppSource] {
        let descriptor = FetchDescriptor<AppSource>()
        return try modelContext.fetch(descriptor)
    }
    
    func addAppSource(_ appSource: AppSource) throws {
        modelContext.insert(appSource)
        try modelContext.save()
    }
    
    func editAppSource(appId: UUID, apply changes: (AppSource) -> Void) throws {
        var descriptor = FetchDescriptor<AppSource>(
            predicate: #Predicate { $0.id == appId }
        )
        
        descriptor.fetchLimit = 1
        
        guard var appSource = try modelContext.fetch(descriptor).first else {
            return
        }
        
        changes(appSource)
        try modelContext.save()
    }
    
    func deleteAppSource(appId: UUID) throws {
        var descriptor = FetchDescriptor<AppSource> (
            predicate: #Predicate { $0.id == appId }
        )
        
        descriptor.fetchLimit = 1
        
        guard let appSource = try modelContext.fetch(descriptor).first else {
            return
        }
        
        modelContext.delete(appSource)
        try modelContext.save()
    }
}
