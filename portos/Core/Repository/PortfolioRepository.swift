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
    @discardableResult
    func create(name: String, targetAmount: Decimal, targetDate: Date) throws -> Portfolio
    func rename(p: Portfolio, to newName: String) throws
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
    
    @discardableResult
    func create(name: String, targetAmount: Decimal, targetDate: Date) throws -> Portfolio {
        let p = Portfolio(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            currentPortfolioValue: 0,
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
