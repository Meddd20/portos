//
//  Holding.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class Holding {
    @Attribute(.unique) var id: UUID
    @Relationship var asset: Asset
    @Relationship var portfolio: Portfolio
    
    var quantity: Decimal
    var averagePricePerUnit: Decimal
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.holding)
    var transactions: [Transaction] = []

    init(asset: Asset, portfolio: Portfolio, quantity: Decimal, averagePricePerUnit: Decimal, createdAt: Date,
        updatedAt: Date) {
        self.id = UUID()
        self.asset = asset
        self.portfolio = portfolio
        self.quantity = quantity
        self.averagePricePerUnit = averagePricePerUnit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
