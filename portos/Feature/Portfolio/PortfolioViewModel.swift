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
    @Published var assetPositions: [AssetPosition] = []
    
    private let service: PortfolioService

    init(service: PortfolioService) {
        self.service = service
    }

    func load() {
        do {
            portfolios = try service.getAllPortfolios()
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
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func getGrowthRate(portfolioName: String) {
        do {
            let (rate, _) = try service.getGrowthRate(portfolioName: portfolioName, valueInPortfolio: portfolioValue)
            growthRate = formatDouble(rate)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func getHoldings(portfolioName: String) {
        do {
            assetPositions = try service.getHoldings(portfolioName: portfolioName)
        } catch {
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
