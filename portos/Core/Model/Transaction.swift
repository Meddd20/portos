//
//  Transaction.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    @Relationship var app: AppSource
    @Relationship var asset: Asset
    @Relationship var portfolio: Portfolio
    @Relationship var holding: Holding
    
    @Relationship(inverse: \TransferTransaction.fromTransaction)
    var transferTransaction: TransferTransaction?
        
    var transactionType: TransactionType
    var quantity: Decimal
    var price: Decimal
    var costBasisPerUnit: Decimal?
    var date: Date
    var tradeCurrency: Currency
    var exchangeRate: Decimal
    var createdAt: Date
    var updatedAt: Date
    
    init(app: AppSource, asset: Asset, portfolio: Portfolio, holding:Holding, transactionType: TransactionType, quantity: Decimal, price: Decimal, costBasisPerUnit: Decimal? = nil, date: Date, tradeCurrency: Currency, exchangeRate: Decimal, createdAt: Date, updatedAt: Date) {
        self.id = UUID()
        self.app = app
        self.asset = asset
        self.portfolio = portfolio
        self.holding = holding
        self.transactionType = transactionType
        self.quantity = quantity
        self.price = price
        self.costBasisPerUnit = costBasisPerUnit
        self.date = date
        self.tradeCurrency = tradeCurrency
        self.exchangeRate = exchangeRate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
