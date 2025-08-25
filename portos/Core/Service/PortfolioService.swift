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
            let limitedHoldings = Array(holdings.prefix(3))
            return AssetPosition(group: assetType.rawValue, holdings: limitedHoldings)
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
            portValue += holding.quantity * holding.asset.lastPrice
            initialCapital += (holding.averagePricePerUnit * holding.quantity)
        }
        portProfit = portValue - initialCapital
        portGrowthRate = portProfit / initialCapital
        
        for portfolio in portfolios {
            var portfolioValue: Decimal = 0.0
            
            let holdingsForPortfolio: [Holding] = holdings
                .filter { $0.portfolio.name == portfolio.name }
            
            var holdingsByType: [String: [Holding]] = [
                "Bonds": [],
                "Stocks": [],
                "Cryptos": [],
                "MutualFunds": [],
                "Options": [],
                "ETFs": []
            ]
            
            for holding in holdingsForPortfolio {
                portfolioValue += holding.quantity * holding.asset.lastPrice
                
                switch holding.asset.assetType {
                case .Bonds:
                    holdingsByType["Bonds"]?.append(holding)
                case .Stocks:
                    holdingsByType["Stocks"]?.append(holding)
                case .Crypto:
                    holdingsByType["Cryptos"]?.append(holding)
                case .MutualFunds:
                    holdingsByType["MutualFunds"]?.append(holding)
                case .Options:
                    holdingsByType["Options"]?.append(holding)
                case .ETF:
                    holdingsByType["ETFs"]?.append(holding)
                default:
                    print("error here")
                }
            }
            
            var portfolioItem: AssetGroup = AssetGroup(
                name: portfolio.name,
                value: formatDecimal(portfolioValue),
                assets: []
            )
            
            for (name, holdings) in holdingsByType {
                if !holdings.isEmpty {
                    let profitAmount: Decimal = holdings.reduce(0) { acc, h in
                        acc + (h.quantity * h.averagePricePerUnit)
                    }
                    
                    let totalValue: Decimal = holdings.reduce(0) { acc, h in
                        acc + (h.quantity * h.asset.lastPrice)
                    }
                    
                    let growthRate: Decimal = (totalValue - profitAmount) / profitAmount
                    
                    let assetAllocation: AssetItem = AssetItem(
                        holding: nil,
                        name: name,
                        value: formatDecimal(totalValue),
                        growthRate: formatDecimal(growthRate),
                        profitAmount: formatDecimal(profitAmount),
                        quantity: "")
                    
                    portfolioItem.assets.append(assetAllocation)
                }
            }
            
            portfolioItems.append(portfolioItem)
        }
        
        let p = PortfolioOverview(
            portfolioValue: formatDecimal(portValue),
            portfolioGrowthRate: formatDecimal(portGrowthRate),
            portfolioProfitAmount: formatDecimal(portProfit),
            groupItems: portfolioItems
        )
        return p
    }
    
    func getPortfolioOverviewByGoal(_ portfolio: String) throws -> PortfolioOverview {
        var portValue: Decimal = 0.0
        var initialCapital: Decimal = 0
        var portGrowthRate: Decimal = 0.0
        var portProfit: Decimal = 0.0
        var totalValueInAssetType: Decimal = 0.0
        var assetGroup: [AssetGroup] = []
        var holdings: [Holding]
        
        holdings = try holdingRepository.getHoldings(byPortfolioName: portfolio)
        
        for holding in holdings {
            portValue += holding.quantity * holding.asset.lastPrice
            initialCapital += (holding.averagePricePerUnit * holding.quantity)
        }
        portProfit = portValue - initialCapital
        portGrowthRate = portProfit / initialCapital
        
        for holding in holdings {
            var holdingsByType: [String: [Holding]] = [
                "Bonds": [],
                "Stocks": [],
                "Cryptos": [],
                "MutualFunds": [],
                "Options": [],
                "ETFs": []
            ]
            
            totalValueInAssetType += holding.quantity * holding.asset.lastPrice
            
            switch holding.asset.assetType {
            case .Bonds:
                holdingsByType["Bonds"]?.append(holding)
            case .Stocks:
                holdingsByType["Stocks"]?.append(holding)
            case .Crypto:
                holdingsByType["Cryptos"]?.append(holding)
            case .MutualFunds:
                holdingsByType["MutualFunds"]?.append(holding)
            case .Options:
                holdingsByType["Options"]?.append(holding)
            case .ETF:
                holdingsByType["ETFs"]?.append(holding)
            default :
                break
            }
            
            for (name, holdings) in holdingsByType {
                if !holdings.isEmpty {
                    let totalValue: Decimal = holdings.reduce(0) { acc, h in
                        acc + (h.quantity * h.asset.lastPrice)
                    }
                    
                    var group = AssetGroup(
                        name: name,
                        value: formatDecimal(totalValue),
                        assets: [])
                    
                    for h in holdings {
                        let totalValue = h.quantity * h.asset.lastPrice
                        let profitAmount: Decimal = holdings.reduce(0) { acc, h in
                            acc + (h.quantity * h.averagePricePerUnit)
                        }
                        let growthRate: Decimal = (totalValue - profitAmount) / profitAmount
                        
                        var quantityStr: String = ""
                        switch h.asset.assetType {
                        case .Bonds:
                            quantityStr = "Rp \(formatDecimal(h.quantity) ?? "")"
                        case .MutualFunds:
                            quantityStr = formatDecimal(h.quantity) ?? ""
                        case .Options:
                            quantityStr = formatDecimal(h.quantity) ?? ""
                        case .Stocks:
                            quantityStr = "\(formatDecimal(h.quantity) ?? "" ) lot"
                        case .Crypto:
                            quantityStr = formatDecimal(h.quantity) ?? ""
                        case .ETF:
                            quantityStr = "\(formatDecimal(h.quantity) ?? "") eth"
                        default:
                            break
                        }
                        
                        let assetItem = AssetItem(
                            holding: h,
                            name: h.asset.name,
                            value: formatDecimal(totalValue),
                            growthRate: formatDecimal(growthRate),
                            profitAmount: formatDecimal(profitAmount),
                            quantity: quantityStr)
                        
                        group.assets.append(assetItem)
                    }
                    assetGroup.append(group)
                    
                }
            }
        }
        
        let p = PortfolioOverview(
            portfolioValue: formatDecimal(portValue),
            portfolioGrowthRate: formatDecimal(portGrowthRate),
            portfolioProfitAmount: formatDecimal(portProfit),
            groupItems: assetGroup
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
