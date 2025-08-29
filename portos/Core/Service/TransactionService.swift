//
//  TransactionService.swift
//  portos
//
//  Created by Medhiko Biraja on 15/08/25.
//

import Foundation
import SwiftData

enum TransactionError: Error {
    case accountNotFound
    case insufficientQuantity
    case repositoryError(String)
}

enum TransferError: Error {
    case samePortfolio
    case accountNotFound
    case insufficientQuantity
    case invalidQuantity
    case holdingNotFound
}

class TransactionService {
    private let holdingRepository: HoldingRepository
    private let transactionRepository: TransactionRepository
    private let portfolioRepository: PortfolioRepository
    private let holdingService: HoldingService
    private let appSourceRepository: AppSourceRepository
    private let assetRepository: AssetRepository
    
    init(transactionRepository: TransactionRepository, holdingRepository: HoldingRepository, portfolioRepository: PortfolioRepository, holdingService: HoldingService, appSourceRepository: AppSourceRepository, assetRepository: AssetRepository) {
        self.transactionRepository = transactionRepository
        self.holdingRepository = holdingRepository
        self.portfolioRepository = portfolioRepository
        self.holdingService = holdingService
        self.appSourceRepository = appSourceRepository
        self.assetRepository = assetRepository
    }
    
    func getAllTransactions(portfolioId: UUID?) throws -> [Transaction] {
        let transactions = try transactionRepository.getAllTransactions()
        if portfolioId != nil {
            return transactions.filter { $0.portfolio.id == portfolioId }
        } else {
            return transactions
        }
    }
    
    func getHoldingTransactions(holdingId: UUID) throws -> [Transaction] {
        try transactionRepository.getAssetHoldingTransactions(holdingId: holdingId)
    }
    
    func getDetailTransaction(transactionId: UUID) -> Transaction? {
        try? transactionRepository.getDetailTransaction(id: transactionId)
    }
    
    func recordBuyTransaction(
        appSource: AppSource,
        asset: Asset,
        portfolio: Portfolio,
        quantity: Decimal,
        price: Decimal,
        date: Date,
        tradeCurrency: Currency,
        exchangeRate: Decimal
    ) throws {
        let holding: Holding
        
        guard quantity > 0, price > 0 else { throw TransactionError.insufficientQuantity }
        
        if let existingHolding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: portfolio.id, assetId: asset.id) {
            try holdingRepository.updateHolding(id: existingHolding.id) { holding in
                try holding.applyBuyTransactions(
                    buyQty: quantity,
                    buyPrice: price,
                    tradeCurrency: tradeCurrency,
                    exchangeRate: exchangeRate
                )
            }
            holding = existingHolding
        } else {
            let newHolding = Holding(
                asset: asset,
                portfolio: portfolio,
                quantity: quantity,
                averagePricePerUnit: price,
                createdAt: .now,
                updatedAt: .now
            )
            
            try holdingRepository.addHolding(newHolding)
            holding = newHolding
        }
        
        let transaction: Transaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: portfolio,
            holding: holding,
            transactionType: .buy,
            quantity: quantity,
            price: price,
            date: date,
            tradeCurrency: tradeCurrency,
            exchangeRate: exchangeRate,
            createdAt: .now,
            updatedAt: .now
        )
        
        transactionRepository.addTransaction(transaction)
    }
    
    func recordSellTransaction(
        appSource: AppSource,
        asset: Asset,
        portfolio: Portfolio,
        holding: Holding,
        quantity: Decimal,
        sellPrice: Decimal,
        date: Date,
        tradeCurrency: Currency,
        exchangeRate: Decimal
    ) throws {
        let portfolioAssetPosition = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
        let accountPosition: [AccountPosition] = portfolioAssetPosition?.accounts ?? []
        
        guard let sellFromAccount = accountPosition.first(where: { $0.appSource == appSource }) else {
            throw TransactionError.accountNotFound
        }
        
        guard quantity <= sellFromAccount.qty else { throw TransactionError.insufficientQuantity }
        
        try holdingRepository.updateHolding(id: holding.id) { holding in
            try holding.applySellTransactions(sellQty: quantity, sellPrice: sellPrice, tradeCurrency: tradeCurrency, exchangeRate: exchangeRate)
        }
        
        let transaction: Transaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: portfolio,
            holding: holding,
            transactionType: .sell,
            quantity: quantity,
            price: sellPrice,
            costBasisPerUnit: holding.averagePricePerUnit,
            date: date,
            tradeCurrency: tradeCurrency,
            exchangeRate: exchangeRate,
            createdAt: .now,
            updatedAt: .now
        )
        
        transactionRepository.addTransaction(transaction)
    }
    
    @MainActor func recordTransferTransaction(
        appSource: AppSource,
        asset: Asset,
        holding: Holding,
        currentPortfolio: Portfolio,
        quantity: Decimal,
        destinationPortfolio: Portfolio,
        date: Date,
        tradeCurrency: Currency,
        exchangeRate: Decimal
    ) throws {
        guard destinationPortfolio.id != currentPortfolio.id else { throw TransferError.samePortfolio }
        
        let portfolioAssetPosition = try holdingService.getHoldingAssetDetail(holdingId: holding.id)
        let accountPosition: [AccountPosition] = portfolioAssetPosition?.accounts ?? []
        
        guard let transferAssetFromApp = accountPosition.first(where: { $0.appSource == appSource }) else {
            throw TransferError.holdingNotFound
        }
        
        guard quantity <= transferAssetFromApp.qty else { throw TransferError.insufficientQuantity }
        guard quantity > 0 else { throw TransferError.invalidQuantity }
        
        let newHolding: Holding
        let basisPerUnit = transferAssetFromApp.avgCost
        if let existingHolding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: destinationPortfolio.id, assetId: asset.id) {
            try holdingRepository.updateHolding(id: existingHolding.id) { holding in
                try holding.applyTransferIn(
                    qty: quantity,
                    pricePerUnit: basisPerUnit,
                    tradeCurrency: tradeCurrency,
                    exchangeRate: exchangeRate
                )
            }
            newHolding = existingHolding
        } else {
            let holding = Holding(
                asset: asset,
                portfolio: destinationPortfolio,
                quantity: quantity,
                averagePricePerUnit: basisPerUnit,
                createdAt: .now,
                updatedAt: .now
            )
            
            try holdingRepository.addHolding(holding)
            newHolding = holding
        }
        
        try holdingRepository.updateHolding(id: holding.id) { holding in
            try holding.applyTransferOut(
                qty: quantity,
                pricePerUnit: basisPerUnit,
                tradeCurrency: tradeCurrency,
                exchangeRate: exchangeRate
            )
        }
        let groupId = UUID()
        
        let transferOutTransaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: currentPortfolio,
            holding: holding,
            transferGroupId: groupId,
            transactionType: .allocateOut,
            quantity: quantity,
            price: basisPerUnit,
            costBasisPerUnit: basisPerUnit,
            date: date,
            tradeCurrency: tradeCurrency,
            exchangeRate: exchangeRate,
            createdAt: .now,
            updatedAt: .now
        )
        
        let transferInTransaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: destinationPortfolio,
            holding: newHolding,
            transferGroupId: groupId,
            transactionType: .allocateIn,
            quantity: quantity,
            price: basisPerUnit,
            costBasisPerUnit: holding.averagePricePerUnit,
            date: date,
            tradeCurrency: tradeCurrency,
            exchangeRate: exchangeRate,
            createdAt: .now,
            updatedAt: .now
        )
        
        transactionRepository.addTransaction(transferOutTransaction)
        transactionRepository.addTransaction(transferInTransaction)
    }
    
    private func revertHolding(holding: Holding, transaction: Transaction, quantity: Decimal, price: Decimal, basis: Decimal?) throws {
        try holdingRepository.updateHolding(id: holding.id) { holding in
            switch transaction.transactionType {
            case .buy:
                let oldCost = holding.quantity * holding.averagePricePerUnit
                let newQty = holding.quantity - quantity
                let newCost = oldCost - (quantity * price)
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                
            case .sell:
                let oldCost = holding.quantity * holding.averagePricePerUnit
                let newQty = holding.quantity + quantity
                let newCost = oldCost + (quantity * (basis ?? Decimal(0)))
                holding.quantity = newQty
                holding.averagePricePerUnit = newQty == 0 ? 0 : newCost / newQty
                
            default: break
            }
            holding.updatedAt = .now
        }
    }
    
    private func applyHolding(holding: Holding, transaction: Transaction, qty: Decimal, price: Decimal, basis: Decimal?) throws {
        try holdingRepository.updateHolding(id: holding.id) { holding in
            switch transaction.transactionType {
            case .buy:
                let oldCost = holding.quantity * holding.averagePricePerUnit
                let newQty = holding.quantity + qty
                let newCost = oldCost + (qty * price)
                holding.quantity = newQty
                holding.averagePricePerUnit = newQty == 0 ? 0 : newCost / newQty
            case .sell:
                let oldCost = holding.quantity * holding.averagePricePerUnit
                let newQty = holding.quantity - qty
                let newCost = oldCost - (qty * (basis ?? Decimal(0)))
                holding.quantity = newQty
                holding.averagePricePerUnit = newQty == 0 ? 0 : newCost / newQty
            default: break
            }
            holding.updatedAt = .now
        }
    }
    
    
    func editTransaction(transactionId: UUID, amount: Decimal, price: Decimal, platform: AppSource, asset: Asset, portfolio: Portfolio, date: Date) throws {
        guard let transaction = try transactionRepository.getDetailTransaction(id: transactionId) else {
            return
        }
        
        let isQuantityChange: Bool = transaction.quantity != amount
        let isPriceChange: Bool = transaction.price != price
        let isPlatformChange: Bool = transaction.app.id != platform.id
        let isPortfolioChange: Bool = transaction.portfolio.id != portfolio.id
        let isDateChange: Bool = transaction.date != date
        
        let oldQty = transaction.quantity
        let oldPrice = transaction.price
        let basis: Decimal?
        
        if transaction.transactionType == .sell {
            basis = transaction.costBasisPerUnit
        } else {
            basis = nil
        }
        
        if isPortfolioChange {
            let oldHolding = transaction.holding
            try revertHolding(holding: oldHolding, transaction: transaction, quantity: oldQty, price: oldPrice, basis: basis)
            
            if let newHolding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: portfolio.id, assetId: asset.id) {
                try applyHolding(holding: newHolding, transaction: transaction, qty: amount, price: price, basis: basis)
            } else {
                if transaction.transactionType == .buy {
                    let newHolding = Holding(
                        asset: asset,
                        portfolio: portfolio,
                        quantity: amount,
                        averagePricePerUnit: price,
                        createdAt: .now,
                        updatedAt: .now
                    )
                    try holdingRepository.addHolding(newHolding)
                } else {
                    throw TransactionError.repositoryError("Destination holding not found for sell/transfer")
                }
            }
            
        } else if isQuantityChange || isPriceChange {
            let holding = transaction.holding
            // revert posisi lama
            try revertHolding(holding: holding, transaction: transaction, quantity: oldQty, price: oldPrice, basis: basis)
            // apply posisi baru
            try applyHolding(holding: holding, transaction: transaction, qty: amount, price: price, basis: basis)
        }
        
        if isQuantityChange || isPriceChange || isPlatformChange || isPortfolioChange || isDateChange {
            try transactionRepository.editTransaction(id: transactionId) { tx in
                if isQuantityChange { tx.quantity = amount }
                if isPriceChange { tx.price = price }
                if isPlatformChange { tx.app = platform }
                if isPortfolioChange { tx.portfolio = portfolio }
                if isDateChange { tx.date = date }
            }
        }
    }
    
    // STEP 1: Isolate the exact line causing the error
//    @MainActor
//    func debugEditTransferTransaction(transferTransactionId: UUID, amount: Decimal, portfolioDestination: Portfolio, platform: AppSource, asset: Asset) throws {
//        print("🔍 Starting debug...")
//        
//        do {
//            print("🔍 Step 1: Fetching platform...")
//            let platformLive = try appSourceRepository.getAppSource(appId: platform.id)
//            guard let platformLive = platformLive else {
//                print("❌ Platform not found")
//                return
//            }
//            print("✅ Platform fetched: \(platformLive.name)")
//            
//            print("🔍 Step 2: Fetching destination portfolio...")
//            let destLive = try portfolioRepository.getPortfolio(id: portfolioDestination.id)
//            guard let destLive = destLive else {
//                print("❌ Portfolio not found")
//                return
//            }
//            print("✅ Portfolio fetched: \(destLive.name)")
//            
//            print("🔍 Step 3: Fetching asset...")
//            let assetLive = try assetRepository.getAsset(id: asset.id)
//            guard let assetLive = assetLive else {
//                print("❌ Asset not found")
//                return
//            }
//            print("✅ Asset fetched: \(assetLive.name)")
//            
//            print("🔍 Step 4: Fetching source transaction...")
//            let transactionFrom = try transactionRepository.getDetailTransaction(id: transferTransactionId)
//            guard let transactionFrom = transactionFrom else {
//                print("❌ Source transaction not found")
//                return
//            }
//            print("✅ Source transaction fetched: \(transactionFrom.id)")
//            
//            print("🔍 Step 5: Getting transfer group...")
//            guard let groupId = transactionFrom.transferGroupId else {
//                print("❌ No transfer group ID")
//                return
//            }
//            print("✅ Transfer group ID: \(groupId)")
//            
//            print("🔍 Step 6: Fetching destination transaction...")
//            let otherTransactionType = (transactionFrom.transactionType == .allocateOut ? TransactionType.allocateIn : TransactionType.allocateOut)
//
//            let transactionTo = try transactionRepository.getDetailTransferTransaction(
//                transferGroupId: groupId,
//                transactionType: otherTransactionType
//            )
//            guard let transactionTo = transactionTo else {
//                print("❌ Destination transaction not found")
//                return
//            }
//            print("✅ Destination transaction fetched: \(transactionTo.id)")
//            
//            // STOP HERE FIRST - if this works, continue to next step
//            print("✅ All entities fetched successfully!")
//            
//        } catch {
//            print("❌ Error during fetch phase: \(error)")
//            print("❌ Error type: \(type(of: error))")
//            if let nsError = error as NSError? {
//                print("❌ NSError domain: \(nsError.domain)")
//                print("❌ NSError code: \(nsError.code)")
//                print("❌ NSError userInfo: \(nsError.userInfo)")
//            }
//            throw error
//        }
//    }

    
    @MainActor
    func editTransferTransaction(transferTransactionId: UUID, amount: Decimal, portfolioDestination: Portfolio, platform: AppSource, asset: Asset) throws {
        guard amount > 0 else { return }
        
        guard
            let platformLive = try appSourceRepository.getAppSource(appId: platform.id),
            let destLive = try portfolioRepository.getPortfolio(id: portfolioDestination.id),
            let assetLive = try assetRepository.getAsset(id: asset.id)
        else { return }

        guard let transactionFrom = try transactionRepository.getDetailTransaction(id: transferTransactionId) else { return }
        guard let groupId = transactionFrom.transferGroupId else { return }
        
        let otherTransactionType: TransactionType = (transactionFrom.transactionType == .allocateOut ? .allocateIn : .allocateOut)
        guard let transactionTo = try transactionRepository.getDetailTransferTransaction(
            transferGroupId: groupId,
            transactionType: otherTransactionType
        ) else { return }
        
        let isAmountChange: Bool = (transactionFrom.quantity != amount)
        let isPlatformChange: Bool = (transactionFrom.app != platformLive)
        let isDestinationChange: Bool = (transactionTo.portfolio.id != destLive.id)
        
        guard isAmountChange || isPlatformChange || isDestinationChange else { return }
        
        let outBasis = transactionFrom.costBasisPerUnit ?? transactionFrom.price
        let inBasis = transactionTo.costBasisPerUnit ?? transactionTo.price
        
        if isDestinationChange {
            try holdingRepository.updateHolding(id: transactionTo.holding.id) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty - transactionTo.quantity
                let newCost = oldCost - (transactionTo.quantity * inBasis)
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
            
            let destinationHolding: Holding
            if let existingHolding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: destLive.id, assetId: assetLive.id) {
                try holdingRepository.updateHolding(id: existingHolding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty + amount
                    let newCost = oldCost + (amount * inBasis)
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
                destinationHolding = existingHolding
            } else {
                let newHolding = Holding(
                    asset: assetLive,
                    portfolio: destLive,
                    quantity: amount,
                    averagePricePerUnit: inBasis,
                    createdAt: .now,
                    updatedAt: .now
                )
                try holdingRepository.addHolding(newHolding)
                destinationHolding = newHolding
            }
            
            try transactionRepository.editTransaction(id: transactionTo.id) { transaction in
                transaction.portfolio = destLive
                transaction.holding = destinationHolding
                if isAmountChange { transaction.quantity = amount }
                if isPlatformChange { transaction.app = platformLive }
                transaction.updatedAt = .now
            }
            
            if isAmountChange || isPlatformChange {
                try transactionRepository.editTransaction(id: transactionFrom.id) { transaction in
                    if isAmountChange { transaction.quantity = amount }
                    if isPlatformChange { transaction.app = platformLive }
                    transaction.updatedAt = .now
                }
            }
            return
        }
        
        if isAmountChange {
            let oldAmount = transactionFrom.quantity
            let delta = amount - oldAmount
            
            if delta != 0 {
                try holdingRepository.updateHolding(id: transactionFrom.holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty - delta
                    let newCost = oldCost - (delta * outBasis)
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }

                try holdingRepository.updateHolding(id: transactionTo.holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty + delta
                    let newCost = oldCost + (delta * inBasis)
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
            }
        }
        
        try transactionRepository.editTransaction(id: transactionFrom.id) { transaction in
            if isAmountChange { transaction.quantity = amount }
            if isPlatformChange { transaction.app = platformLive }
            transaction.updatedAt = .now
        }
        try transactionRepository.editTransaction(id: transactionTo.id) { transaction in
            if isAmountChange { transaction.quantity = amount }
            if isPlatformChange { transaction.app = platformLive }
            transaction.updatedAt = .now
        }
    }
        
    @MainActor
    func deleteTransaction(transactionId: UUID) throws {
        guard let transaction = try transactionRepository.getDetailTransaction(id: transactionId) else {
            return
        }
                
        let holdingId = transaction.holding.id
        let txsQuantity = transaction.quantity
        let tradePrice = transaction.price
        
        switch transaction.transactionType {
        case .buy:
            try holdingRepository.updateHolding(id: holdingId) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty - txsQuantity
                let newCost = oldCost - (txsQuantity * tradePrice)
                
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
            try transactionRepository.deleteTransaction(id: transactionId)
            
        case .sell:
            guard let basis = transaction.costBasisPerUnit else {
                throw TransactionError.repositoryError("missing_cost_basis_per_unit_on_sell".localized)
            }
            
            try holdingRepository.updateHolding(id: holdingId) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty + txsQuantity
                let newCost = oldCost + (txsQuantity * basis)
                
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
            try transactionRepository.deleteTransaction(id: transactionId)
            
        case .allocateOut, .allocateIn:
            let transferTransaction: [Transaction] = try getAllTransactions(portfolioId: transaction.portfolio.id)
                .filter { $0.transferGroupId == transaction.transferGroupId }
            
            guard let allocateOutTransaction = transferTransaction.first(where: { $0.transactionType == .allocateOut }), let allocateInTransaction = transferTransaction.first(where: { $0.transactionType == .allocateIn }) else {
                return
            }
            
            let amount = transaction.quantity
            let outBasis = allocateOutTransaction.costBasisPerUnit ?? allocateOutTransaction.price
            let inBasis = allocateInTransaction.costBasisPerUnit ?? allocateInTransaction.price
            
            try holdingRepository.updateHolding(id: allocateOutTransaction.holding.id) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty + amount
                let newCost = oldCost + (amount * outBasis)
                
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
            
            try holdingRepository.updateHolding(id: allocateInTransaction.holding.id) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty - amount
                let newCost = oldCost - (amount * inBasis)
                
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
            
            try transactionRepository.deleteTransaction(id: allocateOutTransaction.id)
            try transactionRepository.deleteTransaction(id: allocateInTransaction.id)
            
        }
        
    }
}
