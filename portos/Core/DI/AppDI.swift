//
//  AppDI.swift
//  portos
//
//  Created by Niki Hidayati on 19/08/25.
//

import Foundation
import SwiftData

struct AppDI {
    let portfolioRepository: PortfolioRepositoryProtocol
    let holdingRepository: HoldingRepository
    
    let portfolioService: PortfolioService

    static func live(modelContext: ModelContext) -> AppDI {
        let portfolioRepo = PortfolioRepository(ctx: modelContext)
        let holdingRepo = HoldingRepository(modelContext: modelContext)
        
        let portfolioService = PortfolioService(holdingRepository: holdingRepo, portfolioRepository: portfolioRepo)

        return AppDI(
            portfolioRepository: portfolioRepo,
            holdingRepository: holdingRepo,
            portfolioService: portfolioService
        )
    }
}
