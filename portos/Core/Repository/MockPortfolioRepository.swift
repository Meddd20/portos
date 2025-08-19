//
//  MockPortfolioRepository.swift
//  portos
//
//  Created by Niki Hidayati on 18/08/25.
//

import Foundation

class MockPortfolioRepository: PortfolioRepositoryProtocol {
    
    var portfolios: [Portfolio] = []
    var shouldThrow = false
    
    func allPortfolios() throws -> [Portfolio] {
        if shouldThrow { throw NSError(domain: "Mock", code: 1) }
        return portfolios
    }
    
    @discardableResult
    func create(name: String, targetAmount: Decimal, targetDate: Date) throws -> Portfolio {
        if shouldThrow { throw NSError(domain: "Mock", code: 1) }
        
        let portfolio = Portfolio(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            currentPortfolioValue: 10000.00,
            isActive: true,
            createdAt: .now,
            updatedAt: .now
        )
        portfolios.append(portfolio)
        return portfolio
    }
    
    func rename(p: Portfolio, to newName: String) throws {
        if shouldThrow { throw NSError(domain: "Mock", code: 1) }
        
        if let index = portfolios.firstIndex(where: { $0.id == p.id }) {
            portfolios[index].name = newName
        }
    }
    
    func setActive(_ p: Portfolio, _ isActive: Bool) throws {
        if shouldThrow { throw NSError(domain: "Mock", code: 1) }
        
        if let index = portfolios.firstIndex(where: { $0.id == p.id }) {
            portfolios[index].isActive = isActive
        }
    }
    
    @discardableResult
    func delete(id: UUID) throws -> Bool {
        if shouldThrow { throw NSError(domain: "Mock", code: 1) }
        
        if let index = portfolios.firstIndex(where: { $0.id == id }) {
            portfolios.remove(at: index)
            return true
        }
        return false
    }
}
