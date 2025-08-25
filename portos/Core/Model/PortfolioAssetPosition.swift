//
//  PortfolioAssetPosition.swift
//  portos
//
//  Created by Medhiko Biraja on 18/08/25.
//

import Foundation

struct PortfolioAssetPosition {
    let holdingId: UUID
    let assetId: UUID
    let assetSymbol: String
    let currency: Currency
    let totalQty: Decimal
    let avgCost: Decimal
    let portfolioMarketValue: Decimal
    let costBasis: Decimal
    let unrealizedPnLValue: Decimal
    let unrealizedPnLPercentage: Decimal
    let lastPrice: Decimal
    let asOf: Date
    let accounts: [AccountPosition]
    let historyTransactions: [Transaction]
}

struct AccountPosition {
    let appSource: AppSource
    let qty: Decimal
    let avgCost: Decimal
    let lastPrice: Decimal
    let unrealizedPnL: Decimal
    let unrealizedPnLPercentage: Decimal
}
