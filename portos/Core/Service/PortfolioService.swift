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
    
    func getPortfolioValue(portfolio: String) throws -> Int {
        var holdings: [Holding] = try holdingRepository.getAllHoldings()
        
        if portfolio != "All" {
            holdings = holdings
                .filter { $0.portfolio.name == portfolio }
        }
        
        var portfolioValue: Decimal = 0.0
        for holding in holdings {
            portfolioValue += holding.averagePricePerUnit * holding.quantity * holding.lastUpdatedPrice
        }
        
        return NSDecimalNumber(decimal: portfolioValue).intValue
    }
    
    func getProfitAmount(portfolioName: String, valueInPortfolio: Int) throws -> (Int, Bool) {
        var initialCapitalDecimal: Decimal = 0
        var initialCapitalInt: Int
        
        if portfolioName != "All" {
            let portfolio = try portfolioRepository.getPortfolioByName(portfolioName)!
            initialCapitalInt = NSDecimalNumber(decimal: portfolio.currentPortfolioValue).intValue
        } else {
            let portfolios = try portfolioRepository.allPortfolios()
            for portfolio in portfolios {
                initialCapitalDecimal += portfolio.currentPortfolioValue
            }
            initialCapitalInt = NSDecimalNumber(decimal: initialCapitalDecimal).intValue
        }
        
        let profitAmount = valueInPortfolio - initialCapitalInt
        
        if profitAmount > 0 {
            return (profitAmount, true)
        } else {
            return (profitAmount, false)
        }
    }
    
    /// - Returns: A tuple `(growthRate, isProfit)` where:
    ///   - `growthRate` is a `Double` representing the rate of growth.
    ///   - `isProfit` is `true` if growthRate > 0, otherwise `false`.
    func getGrowthRate(portfolioName: String, valueInPortfolio: Int) throws -> (Double, Bool) {
        let valueInPortfolioDecimal = Decimal(valueInPortfolio)
        var initialCapital: Decimal = 0
        
        if portfolioName == "All" {
            let portfolios = try portfolioRepository.allPortfolios()
            for portfolio in portfolios {
                initialCapital += portfolio.currentPortfolioValue
            }
        } else {
            let portfolio = try portfolioRepository.getPortfolioByName(portfolioName)!
            initialCapital = portfolio.currentPortfolioValue
        }
        
        let growthRate = (valueInPortfolioDecimal - initialCapital) / initialCapital
        let growthRateDouble = (growthRate as NSDecimalNumber).doubleValue
        
        if growthRateDouble > 0 {
            return (growthRateDouble, true)
        } else {
            return (growthRateDouble, false)
        }
    }
    
    func getAssetNames(portfolioName: String) throws -> [AssetPosition] {
        var holdings: [Holding] = []
        if portfolioName == "All" {
            holdings = try holdingRepository.getAllHoldings()
        } else {
            holdings = try holdingRepository.getHoldings(byPortfolioName: portfolioName)
        }
        
        let grouped = Dictionary(grouping: holdings, by: { $0.asset.name })

        let positions = grouped.map { (assetName, holdings) in
            let limitedHoldings = Array(holdings.prefix(3))
            return AssetPosition(assetName: assetName, holdings: limitedHoldings)
        }

        return positions
    }
    
    func createPortfolio(name: String, targetAmount: Decimal, targetDate: Date) throws {
        let p = Portfolio(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            currentPortfolioValue: 0,
            isActive: true,
            createdAt: Date.now,
            updatedAt: Date.now
        )
        try portfolioRepository.create(p: p)
    }
}


struct AssetPosition {
    var assetName: String
    var holdings: [Holding]
}
