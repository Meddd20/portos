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
    
    init(transactionRepository: TransactionRepository, holdingRepository: HoldingRepository, portfolioRepository: PortfolioRepository, holdingService: HoldingService) {
        self.transactionRepository = transactionRepository
        self.holdingRepository = holdingRepository
        self.portfolioRepository = portfolioRepository
        self.holdingService = holdingService
    }
    
    func getAllTransactions() throws -> [Transaction] {
        try transactionRepository.getAllTransactions()
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
                
        var transaction: Transaction = Transaction(
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
        var portfolioAssetPosition = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
        var accountPosition: [AccountPosition] = portfolioAssetPosition?.accounts ?? []
        
        guard let sellFromAccount = accountPosition.first(where: { $0.appSourceId == appSource.id }) else {
            throw TransactionError.accountNotFound
        }
        
        guard quantity <= sellFromAccount.qty else { throw TransactionError.insufficientQuantity }
        
        try holdingRepository.updateHolding(id: holding.id) { holding in
            try holding.applySellTransactions(sellQty: quantity, sellPrice: sellPrice, tradeCurrency: tradeCurrency, exchangeRate: exchangeRate)
        }
                
        var transaction: Transaction = Transaction(
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
        
        var portfolioAssetPosition = try holdingService.getHoldingAssetDetail(holdingId: holding.id)
        var accountPosition: [AccountPosition] = portfolioAssetPosition?.accounts ?? []
        
        guard let transferAssetFromApp = accountPosition.first(where: { $0.appSourceId == appSource.id }) else {
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
        
        let transferValue = quantity * transferAssetFromApp.avgCost
        
        var transferOutTransaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: currentPortfolio,
            holding: holding,
            transactionType: .allocateOut,
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
    
        var transferInTransaction = Transaction(
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
        
        transactionRepository.addTransaction(transferInTransaction)
    }
    
    func editTransaction(transactionId: UUID, amount: Decimal, price: Decimal, platform: AppSource, asset: Asset, portfolio:Portfolio, date: Date) throws {
        guard let transaction = try transactionRepository.getDetailTransaction(id: transactionId) else {
            return
        }
        
        let isQuantityChange: Bool = transaction.quantity != amount
        let isPriceChange: Bool = transaction.price != price
        let isPlatformChange: Bool = transaction.app.id != platform.id
        let isPortfolioChange: Bool = transaction.portfolio.id != portfolio.id
        let isDateChange: Bool = transaction.date != date
        
        let txsQuantity = transaction.quantity
        let tradePrice = transaction.price
        guard let basis = transaction.costBasisPerUnit else {
            throw TransactionError.repositoryError("Missing costBasisPerUnit on sell")
        }
        
        if isPortfolioChange {
            // Check if there's a holding available for that platform
            if let holding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: portfolio.id, assetId: asset.id) {
                
                // Change the holding's quantity, averagePricePerUnit, and updatedAt in both current and destination
                // Change the currentPortfolioValue in the current and destination portfolio
                switch transaction.transactionType {
                case .buy:
                    try holdingRepository.updateHolding(id: holding.id) { holding in
                        let oldQty = holding.quantity
                        let oldCost = oldQty * holding.averagePricePerUnit
                        let newQty = oldQty - txsQuantity
                        let newCost = oldCost - (txsQuantity * tradePrice)
                        
                        holding.quantity = newQty
                        holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                        holding.updatedAt = .now
                    }
                                                            
                case .sell:
                    try holdingRepository.updateHolding(id: holding.id) { holding in
                        let oldQty = holding.quantity
                        let oldCost = oldQty * holding.averagePricePerUnit
                        let newQty = oldQty + txsQuantity
                        let newCost = oldCost + (txsQuantity * basis)
                        
                        holding.quantity = newQty
                        holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                        holding.updatedAt = .now
                    }
                                                            
                case .allocateIn:
                    try holdingRepository.updateHolding(id: holding.id) { holding in
                        let oldQty = holding.quantity
                        let oldCost = oldQty * holding.averagePricePerUnit
                        let newQty = oldQty - txsQuantity
                        let newCost = oldCost - (txsQuantity * basis)
                        
                        holding.quantity = newQty
                        holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                        holding.updatedAt = .now
                    }
                                        
                case .allocateOut:
                    try holdingRepository.updateHolding(id: holding.id) { holding in
                        let oldQty = holding.quantity
                        let oldCost = oldQty * holding.averagePricePerUnit
                        let newQty = oldQty + txsQuantity
                        let newCost = oldCost + (txsQuantity * basis)
                        
                        holding.quantity = newQty
                        holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                        holding.updatedAt = .now
                    }
                }
            }
        }
        
        if isPriceChange || isQuantityChange {
            // Change the holding's quantity, averagePricePerUnit, and updatedAt in both current and destination
            // Change the currentPortfolioValue in the current and destination portfolio
            let holding = transaction.holding

            switch transaction.transactionType {
            case .buy:
                try holdingRepository.updateHolding(id: holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty - txsQuantity
                    let newCost = oldCost - (txsQuantity * tradePrice)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
                                                
            case .sell:
                try holdingRepository.updateHolding(id: holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty + txsQuantity
                    let newCost = oldCost + (txsQuantity * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
                
            case .allocateIn:
                try holdingRepository.updateHolding(id: holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty - txsQuantity
                    let newCost = oldCost - (txsQuantity * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
                                
            case .allocateOut:
                try holdingRepository.updateHolding(id: holding.id) { holding in
                    let oldQty = holding.quantity
                    let oldCost = oldQty * holding.averagePricePerUnit
                    let newQty = oldQty + txsQuantity
                    let newCost = oldCost + (txsQuantity * basis)
                    
                    holding.quantity = newQty
                    holding.averagePricePerUnit = (newQty == 0) ? 0 : (newCost / newQty)
                    holding.updatedAt = .now
                }
                
            }
        }
        
        // There's nothing changing
        if !(isQuantityChange || isPriceChange || isPlatformChange || isPortfolioChange || isDateChange) {
            return
        }
        
        try transactionRepository.editTransaction(id: transactionId) { transaction in
            if isQuantityChange { transaction.quantity = amount }
            if isPriceChange { transaction.price = price }
            if isPlatformChange { transaction.app = platform }
            if isPortfolioChange { transaction.portfolio = portfolio }
            if isDateChange { transaction.date = date }
        }
    }
    
    func deleteTransaction(transactionId: UUID) throws {
        guard let transaction = try transactionRepository.getDetailTransaction(id: transactionId) else {
            return
        }
        
        let portfolio = transaction.portfolio
        
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
        
        try transactionRepository.deleteTransaction(id: transactionId)
    }
}
