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
    @Published var profitAmount: Int = 0
    @Published var growthRate: String = ""
    
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
