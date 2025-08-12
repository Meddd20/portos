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
    var assetType: String
    var symbol: String
    var name: String
    var currency: Currency
    var country: String
    
    @Relationship(deleteRule: .deny, inverse: \Holding.asset)
    var holdings: [Holding] = []
    
    @Relationship(deleteRule: .deny, inverse: \Transaction.asset)
    var transactions: [Transaction] = []
    
    init(assetType: String, symbol: String, name: String, currency: Currency, country: String) {
        self.id = UUID()
        self.assetType = assetType
        self.symbol = symbol
        self.name = name
        self.currency = currency
        self.country = country
    }
}

