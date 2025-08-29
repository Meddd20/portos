//
//  PortfolioService.swift
//  portos
//
//  Created by Niki Hidayati on 19/08/25.
//

import Foundation

class PortfolioService {
    private let holdingRepository: HoldingRepository
    private let portfolioRepository: PortfolioRepository
    
    init(holdingRepository: HoldingRepository, portfolioRepository: PortfolioRepository) {
        self.holdingRepository = holdingRepository
        self.portfolioRepository = portfolioRepository
    }
    
    func getAllPortfolios() throws -> [Portfolio] {
        let portfolios = try portfolioRepository.allPortfolios()
        return portfolios
    }
    
    func getHoldings(portfolioName: String) throws -> [AssetPosition] {
        var holdings: [Holding] = []
        if portfolioName == "All" {
            holdings = try holdingRepository.getAllHoldings()
        } else {
            holdings = try holdingRepository.getHoldings(byPortfolioName: portfolioName)
        }
        
        let grouped = Dictionary(grouping: holdings, by: { $0.asset.assetType })

        let positions = grouped.map { (assetType, holdings) in
            return AssetPosition(group: assetType.rawValue, holdings: holdings)
        }

        return positions
    }
    
    func createPortfolio(name: String, targetAmount: Decimal, targetDate: Date) throws {
        let p = Portfolio(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            isActive: true,
            createdAt: Date.now,
            updatedAt: Date.now
        )
        try portfolioRepository.createPortfolio(p: p)
    }
    
    func update(p: Portfolio, newName: String, newTargetAmount: Decimal, newTerm: Int) throws {
        let newTargetDate: Date = Calendar.current.date(byAdding: .year, value: newTerm, to: .now) ?? p.targetDate
        try portfolioRepository.update(p: p, newName: newName, newTargetAmount: newTargetAmount, newTargetDate: newTargetDate)
    }
    
    func delete(id: UUID) throws {
        try portfolioRepository.delete(id: id)
    }
    
    func getPortfolioOverview() throws -> PortfolioOverview {
        var portValue: Decimal = 0.0
        var initialCapital: Decimal = 0
        var portGrowthRate: Decimal = 0.0
        var portProfit: Decimal = 0.0
        var portfolioItems: [AssetGroup] = []
        var holdings: [Holding]
        let portfolios = try portfolioRepository.allPortfolios()
        
        holdings = try holdingRepository.getAllHoldings()
        
        for holding in holdings {
            portValue += holding.quantity * holding.asset.lastPrice * Decimal(holding.asset.assetType.multiplier)
            initialCapital += (holding.averagePricePerUnit * holding.quantity * Decimal(holding.asset.assetType.multiplier))
        }
        portProfit = portValue - initialCapital
        portGrowthRate = portProfit / initialCapital
        
        // Group all holdings by asset type (not by portfolio)
        let grouped = Dictionary(grouping: holdings, by: { $0.asset.assetType })
        
        let groups: [AssetGroup] = grouped.map { (assetType, hs) in
            let groupTotal: Decimal = hs.reduce(0) { acc, h in
                acc + (h.quantity * h.asset.lastPrice * Decimal(h.asset.assetType.multiplier))
            }

            let items: [AssetItem] = hs.map { h in
                let currentValue = h.quantity * h.asset.lastPrice * Decimal(h.asset.assetType.multiplier)
                let cost         = h.quantity * h.averagePricePerUnit * Decimal(h.asset.assetType.multiplier)
                let profit       = currentValue - cost
                let growth       = cost == 0 ? 0 : (profit / cost) * 100

                let qtyStr: String = {
                    switch assetType {
                    case .Stocks:
                        return "\(formatDecimal(h.quantity) ?? "") Share(s)"
                    case .Bonds:
                        return "Rp \(formatDecimal(h.quantity) ?? "")"
                    case .MutualFunds, .Options, .ETF:
                        return formatDecimal(h.quantity) ?? ""
                    case .Crypto:
                        return "\(formatDecimal(h.quantity) ?? "") \(h.asset.ticker.lowercased())"
                    case .StocksId:
                        return "\(formatDecimal(h.quantity) ?? "") Lot"
                    }
                }()

                return AssetItem(
                    holding: h,  // Include the holding reference for currency conversion
                    name: h.asset.name,
                    value: formatDecimal(currentValue),
                    growthRate: growth.rounded(scale: 2),
                    profitAmount: formatDecimal(profit),
                    quantity: qtyStr
                )
            }
                
            return AssetGroup(
                name: assetType.displayName,
                value: formatDecimal(groupTotal),
                assets: items )
        }
        .sorted { ($0.value ?? "") > ($1.value ?? "") }
        
        let p = PortfolioOverview(
            portfolioValue: formatDecimal(portValue),
            portfolioGrowthRate: formatDecimal(portGrowthRate),
            portfolioProfitAmount: formatDecimal(portProfit),
            groupItems: groups
        )
        return p
    }
    
    func getPortfolioOverviewByGoal(_ portfolio: String) throws -> PortfolioOverview {
        let holdings = try holdingRepository.getHoldings(byPortfolioName: portfolio)
        
        let portValue: Decimal = holdings.reduce(0) { $0 + $1.quantity * $1.asset.lastPrice * Decimal($1.asset.assetType.multiplier)}
        let initialCapital: Decimal = holdings.reduce(0) { $0 + $1.quantity * $1.averagePricePerUnit * Decimal($1.asset.assetType.multiplier) }
        let portProfit: Decimal = portValue - initialCapital
        let portGrowthRate: Decimal = initialCapital == 0 ? 0 : (portProfit / initialCapital) * 100
        
        let grouped = Dictionary(grouping: holdings, by: { $0.asset.assetType })
        
        let groups: [AssetGroup] = grouped.map { (assetType, hs) in
        let groupTotal: Decimal = hs.reduce(0) { acc, h in
            acc + (h.quantity * h.asset.lastPrice * Decimal(h.asset.assetType.multiplier))
        }

        let items: [AssetItem] = hs.map { h in
            let currentValue = h.quantity * h.asset.lastPrice * Decimal(h.asset.assetType.multiplier)
            let cost         = h.quantity * h.averagePricePerUnit * Decimal(h.asset.assetType.multiplier)
            let profit       = currentValue - cost
            let growth       = cost == 0 ? 0 : (profit / cost) * 100

            let qtyStr: String = {
                switch assetType {
                case .Stocks:
                    return "\(formatDecimal(h.quantity) ?? "") Share(s)"
                case .Bonds:
                    return "Rp \(formatDecimal(h.quantity) ?? "")"
                case .MutualFunds, .Options, .ETF:
                    return formatDecimal(h.quantity) ?? ""
                case .Crypto:
                    return "\(formatDecimal(h.quantity) ?? "") \(h.asset.ticker.lowercased())"
                case .StocksId:
                    return "\(formatDecimal(h.quantity) ?? "") Lot"
                }
            }()

            return AssetItem(
                holding: h,
                name: h.asset.name,
                value: formatDecimal(currentValue),
                growthRate: growth.rounded(scale: 2),
                profitAmount: formatDecimal(profit),
                quantity: qtyStr
            )
        }
            
        return AssetGroup(
            name: assetType.displayName,
            value: formatDecimal(groupTotal),
            assets: items )
        }
        .sorted { ($0.value ?? "") > ($1.value ?? "") }
        
        let p = PortfolioOverview(
            portfolioValue: formatDecimal(portValue),
            portfolioGrowthRate: formatDecimal(portGrowthRate),
            portfolioProfitAmount: formatDecimal(portProfit),
            groupItems: groups.sorted { ($0.value ?? "") > ($1.value ?? "") }
        )
        
        return p
    }
}
    
    
struct AssetPosition {
    let id = UUID()
    var group: String
    var holdings: [Holding]
}

func formatDecimal(_ value: Decimal,
                   locale: Locale = .current,
                   useGrouping: Bool = true,
                   rounding: NumberFormatter.RoundingMode = .down) -> String? {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.locale = locale
    f.usesGroupingSeparator = useGrouping
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 2
    f.roundingMode = rounding
    
    return f.string(from: NSDecimalNumber(decimal: value))!
}
