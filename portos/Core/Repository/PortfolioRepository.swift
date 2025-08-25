//
//  PortfolioRepository.swift
//  portos
//
//  Created by Niki Hidayati on 14/08/25.
//

import Foundation
import SwiftData

protocol PortfolioRepositoryProtocol {
    func allPortfolios() throws -> [Portfolio]
    func createPortfolio(p : Portfolio) throws
    func update(p: Portfolio, newName: String, newTargetAmount: Decimal, newTargetDate: Date) throws
    func setActive(_ p: Portfolio, _ isActive: Bool) throws
    @discardableResult
    func delete(id: UUID) throws -> Bool
}

struct PortfolioRepository : PortfolioRepositoryProtocol {
    let ctx: ModelContext
    
    init(ctx: ModelContext) { self.ctx = ctx }
    
    func allPortfolios() throws -> [Portfolio] {
        let d = FetchDescriptor<Portfolio>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try ctx.fetch(d)
    }
    
    func createPortfolio(p: Portfolio) throws {
        ctx.insert(p)
        try ctx.save()
    }
    
    func update(p: Portfolio, newName: String, newTargetAmount: Decimal, newTargetDate: Date) throws {
        p.name = newName
        p.targetAmount = newTargetAmount
        p.targetDate = newTargetDate
        p.updatedAt = .now
        try ctx.save()
    }
    
    func editCurrentPortfolioValue(p: Portfolio, to newValue: Decimal) throws {
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
    
    func getPortfolioByName(_ name: String) throws -> Portfolio? {
        let fd = FetchDescriptor<Portfolio>(
            predicate: #Predicate { $0.name == name },
            sortBy: []
        )
        return try ctx.fetch(fd).first
    }
}
