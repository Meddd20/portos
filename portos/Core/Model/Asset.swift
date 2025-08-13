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
    var symbol: String
    var name: String
    var currency: Currency
    var country: String
    
    @Relationship(deleteRule: .cascade, inverse: \Holding.asset)
    var holdings: [Holding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.asset)
    var transactions: [Transaction] = []
    
    init(assetType: AssetType, symbol: String, name: String, currency: Currency, country: String) {
        self.id = UUID()
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.currency = currency
        self.country = country
    }
}
