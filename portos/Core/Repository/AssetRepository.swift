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
    
    
}
