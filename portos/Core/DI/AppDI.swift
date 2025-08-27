//
//  AppDI.swift
//  portos
//
//  Created by Niki Hidayati on 19/08/25.
//

import Foundation
import SwiftData
import SwiftUICore

// 1. Define a KEY so we can store our AppDI in SwiftUI's environment.
private struct AppDIKey: EnvironmentKey {
    static let defaultValue: AppDI = .preview
}

// 2. Add a nice shortcut so we can write `@Environment(\.di)` in Views
// instead of `@Environment(\.someUglyKeyName)`.
extension EnvironmentValues {
    var di: AppDI {
        get { self[AppDIKey.self] }
        set { self[AppDIKey.self] = newValue }
    }
}

// 3. AppDI is just a BOX (or backpack) full of stuff your app needs.
// Instead of creating repositories/services everywhere,
// we make them once here and pass this box around.
struct AppDI {
    let portfolioRepository: PortfolioRepositoryProtocol
    let holdingRepository: HoldingRepository
    let transactionRepository: TransactionRepository
    let assetRepository: AssetRepository
    let appSourceRepository: AppSourceRepository
    
    let holdingService: HoldingService
    let portfolioService: PortfolioService
    let transactionService: TransactionService

    // 4. Factory method: builds a REAL AppDI with live SwiftData repositories.
    // Think of it like: "Fill the backpack with actual tools we’ll use in the app".
    static func live(modelContext: ModelContext) -> AppDI {
        let portfolioRepo = PortfolioRepository(ctx: modelContext)
        let holdingRepo = HoldingRepository(modelContext: modelContext)
        let transactionRepo = TransactionRepository(modelContext: modelContext)
        let assetRepo = AssetRepository(modelContext: modelContext)
        let appSourceRepo = AppSourceRepository(modelContext: modelContext)
        
        let holdingService = HoldingService(
            holdingRepository: holdingRepo,
            portfolioRepository: portfolioRepo,
            transactionRepository: transactionRepo
        )
        
        let portfolioService = PortfolioService(
            holdingRepository: holdingRepo,
            portfolioRepository: portfolioRepo
        )
        
        let transactionService = TransactionService(
            transactionRepository: transactionRepo,
            holdingRepository: holdingRepo,
            portfolioRepository: portfolioRepo,
            holdingService: holdingService,
            appSourceRepository: appSourceRepo,
            assetRepository: assetRepo
        )

        return AppDI(
            portfolioRepository: portfolioRepo,
            holdingRepository: holdingRepo,
            transactionRepository: transactionRepo,
            assetRepository: assetRepo,
            appSourceRepository: appSourceRepo,
            holdingService: holdingService,
            portfolioService: portfolioService,
            transactionService: transactionService
        )
    }
}

// 5. Extension: special version of AppDI for SwiftUI Previews.
// Instead of using your real database, it builds an IN-MEMORY one.
// So when you hit "Preview" in Xcode, you can still see UI without messing real data.
extension AppDI {
    static var preview: AppDI {
        let schema = Schema([AppSource.self, Asset.self, Portfolio.self, Holding.self, Transaction.self])
            let cfg = ModelConfiguration(isStoredInMemoryOnly: true) // <- key change
            let container = try! ModelContainer(for: schema, configurations: cfg)
            let ctx = ModelContext(container)
            return .live(modelContext: ctx)
    }
}
