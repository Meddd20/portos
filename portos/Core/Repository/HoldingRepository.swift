//
//  HoldingRepository.swift
//  portos
//
//  Created by Medhiko Biraja on 14/08/25.
//

import Foundation
import SwiftData

class HoldingRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllHoldings() throws -> [Holding] {
        let descriptor = FetchDescriptor<Holding>()
        return try modelContext.fetch(descriptor)
    }
    
    func getHolding(id: UUID) throws -> Holding? {
        var descriptor = FetchDescriptor<Holding>(
            predicate: #Predicate { $0.id == id}
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func getHoldingByAssetAndPortfolio(portfolioId: UUID, assetId: UUID) throws -> Holding? {
        var descriptor = FetchDescriptor<Holding>(
            predicate: #Predicate { $0.portfolio.id == portfolioId && $0.asset.id == assetId }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func addHolding(_ holding: Holding) throws {
        modelContext.insert(holding)
        try modelContext.save()
    }
    
    func updateHolding(id: UUID, apply changes: (Holding) throws -> Void) throws {
        var descriptor = FetchDescriptor<Holding>(
            predicate: #Predicate<Holding> { $0.id == id }
        )
        
        descriptor.fetchLimit = 1
        
        guard let holding = try modelContext.fetch(descriptor).first else {
            return
        }
        
        try changes(holding)
        holding.updatedAt = .now
        try modelContext.save()
    }
    
    func deleteHolding(id: UUID) throws {
        var descriptor = FetchDescriptor<Holding>(
            predicate: #Predicate<Holding> { $0.id == id }
        )
        
        descriptor.fetchLimit = 1
        
        guard let holding = try modelContext.fetch(descriptor).first else {
            return
        }
        
        modelContext.delete(holding)
        try modelContext.save()
    }
    
    func getHoldings(byPortfolioName name: String) throws -> [Holding] {
        let descriptor = FetchDescriptor<Holding>(
            predicate: #Predicate { holding in
                holding.portfolio.name == name
            }
        )
        return try modelContext.fetch(descriptor)
    }
}
