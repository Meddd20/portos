//
//  PortfolioOverview.swift
//  portos
//
//  Created by Niki Hidayati on 22/08/25.
//

// a model to menampung view for the portfolio overview

import Foundation

struct PortfolioOverview {
    let portfolioValue: String?
    let portfolioGrowthRate: String?
    let portfolioProfitAmount: String?
    let groupItems: [AssetGroup]
}

struct AssetGroup : Identifiable {
    let id: UUID = UUID()
    let name: String?
    let value: String?
    let rawValue: Decimal?  // Raw Decimal value for portfolio totals
    var assets: [AssetItem]
}

struct AssetItem : Identifiable {
    let id: UUID = UUID()
    let holding: Holding?
    let name: String?
    let value: String?
    let rawValue: Decimal?  // Raw Decimal value for currency conversion
    let growthRate: Decimal?
    let profitAmount: String?
    let quantity: String?
}
