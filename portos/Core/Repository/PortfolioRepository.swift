//
//  PortfolioRepository.swift
//  portos
//
//  Created by Niki Hidayati on 14/08/25.
//

import Foundation
import SwiftData

struct PortfolioRepository {
    let ctx: ModelContext
    
    init(ctx: ModelContext) {
        self.ctx = ctx
    }
    
    func allPortfolios() throws -> [Portfolio] {
        let d = FetchDescriptor<Portfolio>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try ctx.fetch(d)
    }
    
    
    @discardableResult
    func createPortfolio(name: String, targetAmount: Decimal, targetDate: Date, currentPortfolioValue: Decimal) throws -> Portfolio {
        let p = Portfolio(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            currentPortfolioValue: currentPortfolioValue,
            isActive: true,
            createdAt: Date.now,
            updatedAt: Date.now
        )
        ctx.insert(p)
        try ctx.save()
        return p
    }
    
    func rename(p: Portfolio, to newName: String) throws {
        p.name = newName
        p.updatedAt = .now
        try ctx.save()
    }
    
    func editCurrentPortfolioValue(p: Portfolio, to newValue: Decimal) throws {
        p.currentPortfolioValue = newValue
        p.updatedAt = .now
        try ctx.save()
    }
    
    func setActive(_ p: Portfolio, _ isActive: Bool) throws {
        p.isActive = isActive
        p.updatedAt = .now
        try ctx.save()
    }
    
    
    @discardableResult
    func delete(id: UUID) throws -> Bool {
        let fd = FetchDescriptor<Portfolio>(
            predicate: #Predicate { $0.id == id },
            sortBy: []
        )
        guard let p = try ctx.fetch(fd).first else {
            return false
        }
        ctx.delete(p)
        do {
            try ctx.save()
            return true
        } catch {
            throw error
        }
    }
}
