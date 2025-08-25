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
    private let transferTransactionRepository: TransferTransactionRepository
    private let holdingService: HoldingService
    
    init(transactionRepository: TransactionRepository, holdingRepository: HoldingRepository, portfolioRepository: PortfolioRepository, transferTransactionRepository: TransferTransactionRepository, holdingService: HoldingService) {
        self.transactionRepository = transactionRepository
        self.holdingRepository = holdingRepository
        self.portfolioRepository = portfolioRepository
        self.transferTransactionRepository = transferTransactionRepository
        self.holdingService = holdingService
    }
    
    func getAllTransactions(portfolioId: UUID?) throws -> [Transaction] {
        var transactions = try transactionRepository.getAllTransactions()
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
    
    func recordTransferTransaction(
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
                
        let transferOutTransaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: currentPortfolio,
            holding: holding,
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
        
        let transferTransaction = TransferTransaction(
            date: date,
            amount: quantity,
            fromTransaction: transferOutTransaction,
            toTransaction: transferInTransaction,
            platform: appSource
        )
        
        transferOutTransaction.transferTransaction = transferTransaction
        transferInTransaction.transferTransaction = transferTransaction
        
        transactionRepository.addTransaction(transferOutTransaction)
        transactionRepository.addTransaction(transferInTransaction)
        print(transferOutTransaction.portfolio.name)
        print(transferInTransaction.portfolio.name)
        
        transferTransactionRepository.addTransferTransaction(transferTransaction)
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
                // bikin holding baru hanya kalau transaksi ini BUY
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
    
    func editTransferTransaction(transferTransactionId: UUID, amount: Decimal, portfolioDestination: Portfolio, platform: AppSource, asset: Asset) throws {
        guard let transferTransaction = try transferTransactionRepository.getTransferTransaction(id: transferTransactionId) else { return }
        
        var isAmountChange: Bool {
            transferTransaction.amount != amount
        }
        var isPortfolioDestinationChange: Bool {
            transferTransaction.toTransaction.portfolio.id != portfolioDestination.id
        }
        var isPlatformChange: Bool {
            transferTransaction.platform != platform
        }
        
        guard isAmountChange || isPortfolioDestinationChange || isPlatformChange else {
            return
        }
        
        if isPortfolioDestinationChange {
            try transferTransactionRepository.editTransferTransaction(id: transferTransactionId) { transferTransaction in
                let oldTransaction = transferTransaction.toTransaction
                let oldHolding = oldTransaction.holding
                guard let basis = oldTransaction.costBasisPerUnit else {
                    throw TransactionError.repositoryError("Missing costBasisPerUnit on transfer")
                }
                
                //Update Old Holding On Old Portfolio
                try holdingRepository.updateHolding(id: oldHolding.id) { holding in
                    let oldQty = oldHolding.quantity
                    let oldCost = oldHolding.quantity * oldHolding.averagePricePerUnit
                    let newQty = oldQty - amount
                    let newCost = oldCost - (amount * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost/newQty)
                    holding.updatedAt = .now
                }
                
                //Update Holding On New Portfolio
                if let holding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: portfolioDestination.id, assetId: asset.id) {
                    try holdingRepository.updateHolding(id: holding.id) { holding in
                        holding.quantity += amount
                        holding.averagePricePerUnit = ((holding.quantity * basis) + (holding.averagePricePerUnit * (holding.quantity - amount))) / holding.quantity
                    }
                    
                } else {
                    try holdingRepository.addHolding(Holding(
                        asset: asset,
                        portfolio: portfolioDestination,
                        quantity: amount,
                        averagePricePerUnit: basis,
                        createdAt: .now,
                        updatedAt: .now
                    ))
                }
            }
        } else {
            let oldAmount = transferTransaction.amount
            let delta = amount - oldAmount
            
            if delta != 0 {
                let oldHolding = transferTransaction.fromTransaction.holding
                guard let basis = transferTransaction.fromTransaction.costBasisPerUnit else {
                    throw TransactionError.repositoryError("Missing costBasisPerUnit on transfer")
                }
                
                try holdingRepository.updateHolding(id: oldHolding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = holding.quantity * holding.averagePricePerUnit
                    let newQty = oldQty - delta
                    let newCost = oldCost - (delta * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost/newQty)
                    holding.updatedAt = .now
                }
                
                let newHolding = transferTransaction.toTransaction.holding
                guard let basis = transferTransaction.toTransaction.costBasisPerUnit else {
                    throw TransactionError.repositoryError("Missing costBasisPerUnit on transfer")
                }
                
                try holdingRepository.updateHolding(id: newHolding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty + delta
                    let newCost = oldCost + (delta * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = newQty == 0 ? 0 : (newCost/newQty)
                    holding.updatedAt = .now
                }
            }
        }
        try transactionRepository.editTransaction(id: transferTransaction.fromTransaction.id) { transaction in
            if isAmountChange {
                transaction.quantity = amount
            }
            
            if isPlatformChange {
                transaction.app = platform
            }
        }
        
        try transactionRepository.editTransaction(id: transferTransaction.toTransaction.id) { transaction in
            if isAmountChange {
                transaction.quantity = amount
            }
            
            if isPlatformChange {
                transaction.app = platform
            }
        }
        
        try transferTransactionRepository.editTransferTransaction(id: transferTransactionId) { transferTransaction in
            transferTransaction.amount = amount
            transferTransaction.platform = platform
        }
    }
    
    func deleteTransaction(transactionId: UUID) throws {
        guard let transaction = try transactionRepository.getDetailTransaction(id: transactionId) else {
            return
        }
        
        let transferTransaction = transaction.transferTransaction
        
        if let transferTransaction {
            try transferTransactionRepository.deleteTransferTransaction(id: transferTransaction.id)
        }
                
        let holdingId = transaction.holding.id
        let txsQuantity = transaction.quantity
        let tradePrice = transaction.price
        print(transaction.transactionType)
                
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
                        
        case .sell:
            guard let basis = transaction.costBasisPerUnit else {
                throw TransactionError.repositoryError("Missing costBasisPerUnit on sell")
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
                    
        case .allocateIn:
            guard let basis = transaction.costBasisPerUnit else {
                throw TransactionError.repositoryError("Missing costBasisPerUnit on allocateIn")
            }
            
            try holdingRepository.updateHolding(id: holdingId) { holding in
                let oldQty = holding.quantity
                let oldCost = oldQty * holding.averagePricePerUnit
                let newQty = oldQty - txsQuantity
                let newCost = oldCost - (txsQuantity * basis)
                
                holding.quantity = newQty
                holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                holding.updatedAt = .now
            }
                    
        case .allocateOut:
            guard let basis = transaction.costBasisPerUnit else {
                throw TransactionError.repositoryError("Missing costBasisPerUnit on allocateOut")
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
        }
        
        if transferTransaction == nil {
            print("true")
            try transactionRepository.deleteTransaction(id: transactionId)
        }
    }
}
