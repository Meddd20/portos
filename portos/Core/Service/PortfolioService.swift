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
    
    // fungsi buat get portfolio values/get values dari setiap asset di portfolio
    func getCurrentValue(holdings: [Holding]) throws -> Int {
        var portfolioValue: Decimal = 0.0
        
        for holding in holdings {
            portfolioValue += (holding.quantity * holding.lastUpdatedPrice)
        }
        
        return NSDecimalNumber(decimal: portfolioValue).intValue
    }
    
    func getPortfolioValue(portfolio: String) throws -> Int {
        var holdings: [Holding] = try holdingRepository.getAllHoldings()
        
        if portfolio != "All" {
            holdings = holdings
                .filter { $0.portfolio.name == portfolio }
        }
        
        var portfolioValue: Decimal = 0.0
        for holding in holdings {
            portfolioValue += holding.quantity * holding.lastUpdatedPrice
        }
        
        return NSDecimalNumber(decimal: portfolioValue).intValue
    }
    
    func getProfitAmount(portfolioName: String, valueInPortfolio: Int) throws -> (Int, Bool) {
        var initialCapital: Decimal = 0
        let valueInPortfolioDecimal = Decimal(valueInPortfolio)
        
        if portfolioName != "All" {
            let holdings = try holdingRepository.getHoldings(byPortfolioName: portfolioName)
            for holding in holdings {
                initialCapital += (holding.averagePricePerUnit * holding.quantity)
            }
        } else {
            let holdings = try holdingRepository.getAllHoldings()
            for holding in holdings {
                initialCapital += (holding.averagePricePerUnit * holding.quantity)
            }
        }
        
        print("profitAmount1 ===== pakai holding.averagePricePerUnit * holding.quantity")
        let profitAmount = valueInPortfolioDecimal - initialCapital
        print("profitAmount DECIMAL: \(profitAmount)")
        let profitAmountInt = NSDecimalNumber(decimal: profitAmount).intValue
        print("profitAmount INT: \(profitAmountInt)")
        
        return (profitAmountInt, profitAmountInt > 0)
    }
    
    func getProfitAmount2(portfolioName: String, valueInPortfolio: Int) throws -> (Int, Bool) {
        var initialCapital: Decimal = 0
        let valueInPortfolioDecimal = Decimal(valueInPortfolio)
        
        if portfolioName != "All" {
            let portfolio = try portfolioRepository.getPortfolioByName(portfolioName)!
            initialCapital = portfolio.currentPortfolioValue
        } else {
            let portfolios = try portfolioRepository.allPortfolios()
            for portfolio in portfolios {
                initialCapital += portfolio.currentPortfolioValue
            }
        }
        
        print("profitAmount2 ===== pakai portfolio.currentPortfolioValue")
        let profitAmount = valueInPortfolioDecimal - initialCapital
        print("profitAmount2 DECIMAL: \(profitAmount)")
        let profitAmountInt = NSDecimalNumber(decimal: profitAmount).intValue
        print("profitAmount2 INT: \(profitAmountInt)")
        
        return (profitAmountInt, profitAmountInt > 0)
    }
    
    /// - Returns: A tuple `(growthRate, isProfit)` where:
    ///   - `growthRate` is a `Double` representing the rate of growth.
    ///   - `isProfit` is `true` if growthRate > 0, otherwise `false`.
    func getGrowthRate2(portfolioName: String, valueInPortfolio: Int) throws -> (Double, Bool) {
        let valueInPortfolioDecimal = Decimal(valueInPortfolio)
        var initialCapital: Decimal = 0
        
        if portfolioName != "All" {
            let holdings = try holdingRepository.getHoldings(byPortfolioName: portfolioName)
            for holding in holdings {
                initialCapital += (holding.averagePricePerUnit * holding.quantity)
            }
        } else {
            let holdings = try holdingRepository.getAllHoldings()
            for holding in holdings {
                initialCapital += (holding.averagePricePerUnit * holding.quantity)
            }
        }
        
        guard initialCapital != 0 else { return (0, false) }
        
        let growthRate = (valueInPortfolioDecimal - initialCapital) / initialCapital
        print("growthRate2 ===== pakai holding.averagePricePerUnit * holding.quantity")
        print("growthRate2: \(growthRate)")
        let growthRateDouble = (growthRate as NSDecimalNumber).doubleValue
        
        return (growthRateDouble, growthRateDouble > 0)
    }
    
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
        
        guard initialCapital != 0 else { return (0, false) }
        
        let growthRate = (valueInPortfolioDecimal - initialCapital) / initialCapital
        print("growthRate1 ===== pakai portfolio.currentPortfolioValue")
        print("growthRate1: \(growthRate)")
        let growthRateDouble = (growthRate as NSDecimalNumber).doubleValue
        
        return (growthRateDouble, growthRateDouble > 0)
    }
    
//    func getGrowthRateNew(holdings: [Holding]) {
//        for holding in holdings {
//            <#body#>
//        }
//    }
    
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
            return AssetPosition(assetType: assetType, holdings: limitedHoldings)
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
    let id = UUID()
    var assetType: AssetType
    var holdings: [Holding]
}
