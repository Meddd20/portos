//
//  Asset.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class Asset {
    @Attribute(.unique) var id: UUID
    var assetType: AssetType
    var symbol: String // = symbol
    var name: String
    var currency: Currency
    var country: String
    var lastPrice: Decimal
    var asOf: Date
    var assetId: String // id for the api call
    var yTicker: String? // id to call chart api -- yahooticker
    var ticker: String = "" // the real ticker
    
    @Relationship(deleteRule: .cascade, inverse: \Holding.asset)
    var holdings: [Holding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.asset)
    var transactions: [Transaction] = []
    
    init(assetType: AssetType, symbol: String, name: String, currency: Currency, country: String, lastPrice: Decimal, asOf: Date, assetId: String, yTicker: String? = nil, ticker: String) {
        self.id = UUID()
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.currency = currency
        self.country = country
        self.lastPrice = lastPrice
        self.asOf = asOf
        self.assetId = assetId
        self.yTicker = yTicker
        self.ticker = ticker
    }
}
