//
//  HoldingService.swift
//  portos
//
//  Created by Medhiko Biraja on 18/08/25.
//

import Foundation

class HoldingService {
    private let holdingRepository: HoldingRepository
    private let portfolioRepository: PortfolioRepository
    private let transactionRepository: TransactionRepository
    
    init(holdingRepository: HoldingRepository, portfolioRepository: PortfolioRepository, transactionRepository: TransactionRepository) {
        self.holdingRepository = holdingRepository
        self.portfolioRepository = portfolioRepository
        self.transactionRepository = transactionRepository
    }
    
    func getHoldingAssetDetail(holdingId: UUID) throws -> PortfolioAssetPosition? {
        guard let holdingAssetTransactions = try? transactionRepository.getAssetHoldingTransactions(holdingId: holdingId) else {
            return nil
        }
        
        guard let holdingDetail = try? holdingRepository.getHolding(id: holdingId) else {
            return nil
        }
        
        let marketValue = holdingDetail.quantity * holdingDetail.asset.lastPrice
        let costBasis = holdingDetail.quantity * holdingDetail.averagePricePerUnit
        let unrealizedPnLValue = (marketValue - costBasis)
        let unrealizedPnLPercentage = (unrealizedPnLValue / costBasis)
                            
        return PortfolioAssetPosition(
            holdingId: holdingId,
            assetId: holdingDetail.asset.id,
            assetSymbol: holdingDetail.asset.symbol,
            currency: holdingDetail.asset.currency,
            totalQty: holdingDetail.quantity,
            avgCost: holdingDetail.averagePricePerUnit,
            portfolioMarketValue: marketValue,
            costBasis: costBasis,
            unrealizedPnLValue: unrealizedPnLValue,
            unrealizedPnLPercentage: unrealizedPnLPercentage,
            lastPrice: holdingDetail.asset.lastPrice,
            asOf: holdingDetail.asset.asOf,
            accounts: AccountHoldingPosition(from: holdingAssetTransactions),
            historyTransactions: holdingAssetTransactions
        )
    }
    
    private func AccountHoldingPosition(from transaction: [Transaction]) -> [AccountPosition] {
        let transactionsGroupByApp = Dictionary(grouping: transaction, by: { $0.app })
        var result: [AccountPosition] = []
        
        for (app, items) in transactionsGroupByApp {
            let sortedTransaction = items.sorted { $0.date < $1.date }
            
            var qty: Decimal = 0
            var buyCost: Decimal = 0
            
            for transaction in sortedTransaction {
                let currentAveragePrice: Decimal = (qty == 0) ? 0 : (buyCost / qty)
                switch transaction.transactionType {
                case .buy:
                    qty += transaction.quantity
                    buyCost += transaction.quantity * transaction.price
                    
                case .sell:
                    qty -= transaction.quantity
                    buyCost -= transaction.quantity * currentAveragePrice
                    
                case .allocateIn:
                    qty += transaction.quantity
                    buyCost += transaction.quantity * transaction.price
                    
                case .allocateOut:
                    qty -= transaction.quantity
                    buyCost -= transaction.quantity * currentAveragePrice
                    
                }
            }
            
            let avgCost = (qty == 0) ? 0 : buyCost / qty
            let lastPrice = sortedTransaction.last?.asset.lastPrice ?? 0
            let unrealizedPnL = (lastPrice - avgCost) * qty
            let unrealizedPnLPercentage: Decimal? = avgCost != 0 ? (unrealizedPnL / avgCost) * 100 : nil
            
            result.append(AccountPosition(
                appSource: app,
                qty: qty,
                avgCost: avgCost,
                lastPrice: lastPrice,
                unrealizedPnL: unrealizedPnL,
                unrealizedPnLPercentage: unrealizedPnLPercentage ?? 0
            ))
        }
        return result.filter { $0.qty != 0 }
    }
    
}
