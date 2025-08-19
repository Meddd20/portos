//
//  Portfolio.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class Portfolio {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetAmount: Decimal
    var targetDate: Date
    var currentPortfolioValue: Decimal
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Holding.portfolio)
    var holdings: [Holding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.portfolio)
    var transactions: [Transaction] = []
    
    init(name: String, targetAmount: Decimal, targetDate: Date, currentPortfolioValue: Decimal, isActive: Bool, createdAt: Date, updatedAt: Date) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.targetDate = targetDate
        self.currentPortfolioValue = currentPortfolioValue
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
