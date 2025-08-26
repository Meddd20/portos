//
//  AssetRepository.swift
//  portos
//
//  Created by Niki Hidayati on 19/08/25.
//

import Foundation
import SwiftData

class AssetRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllAsset() throws -> [Asset] {
        let descriptor = FetchDescriptor<Asset>()
        return try modelContext.fetch(descriptor)
    }
    
    func getAsset(id: UUID) throws -> Asset? {
        var d = FetchDescriptor<Asset>(
            predicate: #Predicate { $0.id == id }
        )
        d.fetchLimit = 1
        return try modelContext.fetch(d).first
    }
    
    
}
