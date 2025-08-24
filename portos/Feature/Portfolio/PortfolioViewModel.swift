//
//  PortfolioViewModel.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import Foundation
import SwiftData

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var portfolios: [Portfolio] = []
    @Published var error: String?
    @Published var portfolioValue: Int = 0
    @Published var profitAmount: Int = 20
    @Published var growthRate: String = "5.5"
//    @Published var assetPositions: [AssetPosition] = []
    
    @Published var portfolioOverview: PortfolioOverview = PortfolioOverview(portfolioValue: "default", portfolioGrowthRate: "default", portfolioProfitAmount: "default", groupItems: [])
    
    private let service: PortfolioService

    init(service: PortfolioService) {
        self.service = service
        getPortfolioOverview()
    }

    func load() {
        do {
            portfolios = try service.getAllPortfolios()
            print(portfolios.count)
        }
        catch { self.error = error.localizedDescription }
    }
    
    func getPortfolioValue(portfolioName: String){
        do {
            portfolioValue = try service.getPortfolioValue(portfolio: portfolioName)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func getProfitAmount(portfolioName: String) {
        do {
            (profitAmount, _) = try service.getProfitAmount(portfolioName: portfolioName, valueInPortfolio: portfolioValue)
            print("get profit amount --> \(profitAmount)")
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func getGrowthRate(portfolioName: String) {
        do {
            let (rate, _) = try service.getGrowthRate(portfolioName: portfolioName, valueInPortfolio: portfolioValue)
            growthRate = formatDouble(rate)
            print("growth rate --> \(rate)")
        } catch {
            self.error = error.localizedDescription
        }
    }
    
//    func getHoldings(portfolioName: String) {
//        do {
//            assetPositions = try service.getHoldings(portfolioName: portfolioName)
//        } catch {
//            self.error = error.localizedDescription
//        }
//    }
    
    func getValue(holdings: [Holding]) -> Int {
        var value: Int = 0
        do {
            value = try service.getValueByHoldings(holdings: holdings)
            return value
        }
        catch {
            self.error = error.localizedDescription
        }
        return value
    }
    
    func getGrowthRateByHoldings(holdings: [Holding], currentValue: Int) -> Double {
        var rate: Double = 0
        var isSuccess: Bool = false
        
        (rate, isSuccess) = service.getGrowthRateByHoldings(holdings: holdings, currentValue: Decimal(currentValue))
        if isSuccess == false {
            self.error = "Failed to calculate growth rate"
            return 0
        }
        
        return rate
    }
    
    func getHoldingValue(holding: Holding) -> String {
        return "\(holding.quantity * holding.asset.lastPrice)"
    }
    
    func getGrowthRateOnHolding(holding: Holding) -> String {
        let res = ((holding.quantity * holding.asset.lastPrice) - (holding.quantity * holding.averagePricePerUnit)) / (holding.quantity * holding.averagePricePerUnit)
        
        let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2

        return formatter.string(from: res as NSDecimalNumber) ?? "0.00"
    }
    
    func getPortfolioOverview(portfolioName: String? = nil) {
        do {
            if portfolioName == nil {
                portfolioOverview = try service.getPortfolioOverview()
            } else {
                portfolioOverview = try service.getPortfolioOverviewByGoal(portfolioName!)
            }
            
            print("portfolioOverview: ------- \(portfolioOverview)")
        }
        catch {
            self.error = error.localizedDescription
        }
    }
    
    func formatDouble(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
