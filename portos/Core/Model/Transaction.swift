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
    
    var transactionType: TransactionType
    var quantity: Decimal
    var price: Decimal
    var date: Date
    var tradeCurrency: Currency
    var exchangeRate: Decimal
    var createdAt: Date
    
    init(app: AppSource, asset: Asset, portfolio: Portfolio, transactionType: TransactionType, quantity: Decimal, price: Decimal, date: Date, tradeCurrency: Currency, exchangeRate: Decimal, createdAt: Date) {
        self.id = UUID()
        self.app = app
        self.asset = asset
        self.portfolio = portfolio
        self.transactionType = transactionType
        self.quantity = quantity
        self.price = price
        self.date = date
        self.tradeCurrency = tradeCurrency
        self.exchangeRate = exchangeRate
        self.createdAt = createdAt
    }
}
