//
//  ContentView.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        let di = AppDI.live(modelContext: modelContext)
        NavigationStack(path: $navigationManager.path) {
            PortfolioScreen(di: di)
                .navigationDestination(for: NavigationRoute.self) { route in
                    route.destination(di: di)
                }
        }
        .environmentObject(navigationManager)
    }
}

#Preview {
    ContentView()
}

extension Portfolio {
    static var dummy: Portfolio {
        Portfolio(
            name: "Dummy Portfolio",
            targetAmount: 100_000,
            targetDate: .now,
            isActive: true,
            createdAt: .now,
            updatedAt: .now
        )
    }
}

extension AppSource {
    static var dummy: AppSource {
        AppSource(name: "Bibit")
    }
}

enum NavigationRoute: Hashable {
    // Asset and transaction routes
    case searchAsset(currentPortfolio: Portfolio?)
    case detailHolding(holding: Holding)
    case transactionHistory(portfolio: Portfolio?)
    
    // Trade transaction routes
    case buyAsset(asset: Asset, portfolio: Portfolio?)
    case sellAsset(asset: Asset, portfolio: Portfolio?, holding: Holding)
    case editTransaction(transaction: Transaction, transactionMode: TransactionMode, asset: Asset, portfolio: Portfolio?)
    
    // Transfer transaction routes
    case transferAsset(asset: Asset, holding: Holding, transferMode: TransferMode)
    case editTransfer(transaction: Transaction, asset: Asset, holding: Holding, transferMode: TransferMode)
    
    // Generic trade transaction with all parameters
    case tradeTransaction(
        transactionMode: TransactionMode,
        transaction: Transaction? = nil,
        holding: Holding? = nil,
        asset: Asset,
        portfolio: Portfolio?
    )
}

extension NavigationRoute {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .searchAsset(let portfolio):
            hasher.combine("searchAsset")
            hasher.combine(portfolio?.id)
        case .detailHolding(let holding):
            hasher.combine("detailHolding")
            hasher.combine(holding.id)
        case .transactionHistory(let portfolio):
            hasher.combine("transactionHistory")
            hasher.combine(portfolio?.id)
        case .buyAsset(let asset, let portfolio):
            hasher.combine("buyAsset")
            hasher.combine(asset.id)
            hasher.combine(portfolio?.id)
        case .sellAsset(let asset, let portfolio, let holding):
            hasher.combine("sellAsset")
            hasher.combine(asset.id)
            hasher.combine(portfolio?.id)
            hasher.combine(holding.id)
        case .editTransaction(let transaction, let transactionMode, let asset, let portfolio):
            hasher.combine("editTransaction")
            hasher.combine(transaction.id)
            hasher.combine(transactionMode)
            hasher.combine(asset.id)
            hasher.combine(portfolio?.id)
        case .transferAsset(let asset, let holding, let transferMode):
            hasher.combine("transferAsset")
            hasher.combine(asset.id)
            hasher.combine(holding.id)
            hasher.combine(transferMode)
        case .editTransfer(let transaction, let asset, let holding, let transferMode):
            hasher.combine("editTransfer")
            hasher.combine(transaction.id)
            hasher.combine(asset.id)
            hasher.combine(holding.id)
            hasher.combine(transferMode)
        case .tradeTransaction(let transactionMode, let transaction, let holding, let asset, let portfolio):
            hasher.combine("tradeTransaction")
            hasher.combine(transactionMode)
            hasher.combine(transaction?.id)
            hasher.combine(holding?.id)
            hasher.combine(asset.id)
            hasher.combine(portfolio?.id)
        }
    }
}

extension NavigationRoute {
    @ViewBuilder
    func destination(di: AppDI) -> some View {
        switch self {
        case .searchAsset(let portfolio):
            SearchAssetView(di: di, currentPortfolioAt: portfolio)
        case .detailHolding(let holding):
            DetailHoldingView(di: di, holding: holding)
        case .transactionHistory(let portfolio):
            TransactionHistoryView(di: di, portfolio: portfolio)
        case .buyAsset(let asset, let portfolio):
            TradeTransactionView(
                di: di,
                transactionMode: .buy,
                asset: asset,
                currentPortfolioAt: portfolio
            )
        case .sellAsset(let asset, let portfolio, let holding):
            TradeTransactionView(
                di: di,
                transactionMode: .liquidate,
                holding: holding,
                asset: asset,
                currentPortfolioAt: portfolio
            )
        case .editTransaction(let transaction, let transactionMode, let asset, let portfolio):
            TradeTransactionView(
                di: di,
                transactionMode: transactionMode,
                transaction: transaction,
                asset: asset,
                currentPortfolioAt: portfolio
            )
        case .transferAsset(let asset, let holding, let transferMode):
            TransferTransactionView(
                di: di,
                asset: asset,
                transferMode: transferMode,
                holding: holding
            )
        case .editTransfer(let transaction, let asset, let holding, let transferMode):
            TransferTransactionView(
                di: di,
                asset: asset,
                transferMode: transferMode,
                holding: holding,
                transaction: transaction
            )
        case .tradeTransaction(let transactionMode, let transaction, let holding, let asset, let portfolio):
            TradeTransactionView(
                di: di,
                transactionMode: transactionMode,
                transaction: transaction,
                holding: holding,
                asset: asset,
                currentPortfolioAt: portfolio
            )
        }
    }
}

enum BackAction {
    case popOnce
    case popToRoot
}

@MainActor
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    private var backStack: [BackAction] = []

    func push(_ route: NavigationRoute, back: BackAction = .popOnce) {
        path.append(route)
        backStack.append(back)
    }

    func popToRoot() {
        print("POP TO ROOT before: path.count=\(path.count) back=\(backStack)")
        while !path.isEmpty {
            path.removeLast()
        }
        backStack.removeAll()
        print("POP TO ROOT after: path.count=\(path.count) back=\(backStack)")
    }

    func popLast() {
        if !path.isEmpty { path.removeLast() }
        if !backStack.isEmpty { backStack.removeLast() }
    }

    func back() {
        guard let last = backStack.last else { popLast(); return }
        print("back() last =", last)
        switch last {
        case .popOnce: popLast()
        case .popToRoot: popToRoot()
        }
    }
    
    func reset() {
        path = NavigationPath()
        backStack.removeAll()
    }
}
