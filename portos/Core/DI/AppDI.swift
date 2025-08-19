//
//  AppDI.swift
//  portos
//
//  Created by Niki Hidayati on 15/08/25.
//

// Dependency Injection

//struct AppDI {
//    struct Repos {
//        let portfolio: PortfolioRepository
////        let holding: HoldingRepository
////        let transaction: TransactionRepository
//    }
//
//    let container: ModelContainer
//    let repos: Repos
//
//    @MainActor
//    static func live() -> AppDI {
//        let schema = Schema([Portfolio.self, Holding.self, Transaction.self])
//        let container = try! ModelContainer(for: schema)
//        let ctx = container.mainContext
//        
//        let portfolio = PortfolioRepository(ctx: ctx)
////        let holding = HoldingRepository(ctx: ctx)
////        let transaction = TransactionRepository(ctx: ctx)
//
//        return .init(container: container,
//                     repos: .init(portfolio: portfolio)) // , holding: holding, transaction: transaction
//    }
//}

import SwiftUI
import SwiftData
import Foundation

class DIContainer: ObservableObject {
    private var _portfolioRepository: PortfolioRepositoryProtocol?
    
    var portfolioRepository: PortfolioRepositoryProtocol {
        guard let repository = _portfolioRepository else {
            fatalError("ModelContext belum di-inject! Pastikan setModelContext() dipanggil dulu.")
        }
        return repository
    }
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self._portfolioRepository = PortfolioRepository(ctx: context)
    }
    
    // Factory method untuk create ViewModel
    @MainActor func makePortfolioViewModel() -> PortfolioViewModel {
        return PortfolioViewModel(repo: portfolioRepository)
    }
    
    // Factory method untuk create Repository (optional, untuk flexibility)
    func makePortfolioRepository() -> PortfolioRepositoryProtocol {
        return portfolioRepository
    }
}
