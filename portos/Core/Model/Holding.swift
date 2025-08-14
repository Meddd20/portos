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
    @Relationship var app: AppSource
    @Relationship var asset: Asset
    @Relationship var portfolio: Portfolio
    
    var quantity: Decimal
    var averagePricePerUnit: Decimal
    var lastUpdatedPrice: Decimal
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.holding)
    var transactions: [Transaction] = []

    init(app: AppSource, asset: Asset, portfolio: Portfolio, quantity: Decimal, averagePricePerUnit: Decimal, lastUpdatedPrice: Decimal, createdAt: Date,
        updatedAt: Date) {
        self.id = UUID()
        self.app = app
        self.asset = asset
        self.portfolio = portfolio
        self.quantity = quantity
        self.averagePricePerUnit = averagePricePerUnit
        self.lastUpdatedPrice = lastUpdatedPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
