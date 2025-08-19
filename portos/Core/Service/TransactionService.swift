//
//  TransactionService.swift
//  portos
//
//  Created by Medhiko Biraja on 15/08/25.
//

import Foundation
import SwiftData

class TransactionService {
    private let transactionRepository: TransactionRepository
    private let holdingRepository: HoldingRepository
    
    init(transactionRepository: TransactionRepository, holdingRepository: HoldingRepository) {
        self.transactionRepository = transactionRepository
        self.holdingRepository = holdingRepository
    }
    
    func getAllTransactions() throws -> [Transaction] {
        try transactionRepository.getAllTransactions()
    }
    
    func getHoldingTransactions(holdingId: UUID) throws -> [Transaction] {
        try transactionRepository.getAssetHoldingTransactions(holdingId: holdingId)
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
        if let existingHolding = try holdingRepository.getHoldingByAssetAndPortfolio(portfolioId: portfolio.id, assetId: asset.id) {
            try holdingRepository.updateHolding(id: existingHolding.id) { holding in
                try? holding.applyBuyTransactions(
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
        price: Decimal,
        date: Date,
        tradeCurrency: Currency,
        exchangeRate: Decimal
    ) {
        
        var transaction: Transaction = Transaction(
            app: appSource,
            asset: asset,
            portfolio: portfolio,
            holding: holding,
            transactionType: .sell,
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
    
    func getDetailTransaction(transactionId: UUID) -> Transaction? {
       try? transactionRepository.getTransaction(id: transactionId)
    }
    
    
    
    
}
