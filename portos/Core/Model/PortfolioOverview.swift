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
    var assets: [AssetItem]
}

struct AssetItem : Identifiable {
    let id: UUID = UUID()
    let name: String?
    let value: String?
    let growthRate: String?
    let profitAmount: String?
    let quantity: String?
}
