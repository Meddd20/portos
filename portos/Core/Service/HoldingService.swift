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
        let multiplier = Decimal(holdingDetail.asset.assetType.multiplier)
        let marketValue = holdingDetail.quantity * holdingDetail.asset.lastPrice * multiplier
        let costBasis = holdingDetail.quantity * holdingDetail.averagePricePerUnit * multiplier
        let unrealizedPnLValue = (marketValue - costBasis)
        let unrealizedPnLPercentage = (unrealizedPnLValue / costBasis * 100)
                            
        return PortfolioAssetPosition(
            holdingId: holdingId,
            assetId: holdingDetail.asset.id,
            assetSymbol: holdingDetail.asset.symbol,
            currency: holdingDetail.asset.currency,
            totalQty: holdingDetail.quantity,
            avgCost: holdingDetail.averagePricePerUnit.roundedWithoutFraction(),
            portfolioMarketValue: marketValue.roundedWithoutFraction(),
            costBasis: costBasis.roundedWithoutFraction(),
            unrealizedPnLValue: unrealizedPnLValue.roundedWithoutFraction(),
            unrealizedPnLPercentage: unrealizedPnLPercentage,
            lastPrice: holdingDetail.asset.lastPrice.roundedWithoutFraction(),
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

            let multiplier = Decimal(sortedTransaction.last?.asset.assetType.multiplier ?? 1)
            let avgCost = (qty == 0) ? 0 : buyCost / qty
            let lastPrice = sortedTransaction.last?.asset.lastPrice ?? 0
            let marketValue = lastPrice * qty * multiplier
            let costBasis   = avgCost * qty * multiplier
            let unrealizedPnL = marketValue
            let unrealizedPnLPercentage: Decimal? = costBasis != 0 ? (unrealizedPnL / costBasis) * 100 : nil
            
            result.append(AccountPosition(
                appSource: app,
                qty: qty,
                avgCost: avgCost.roundedWithoutFraction(),
                lastPrice: lastPrice.roundedWithoutFraction(),
                unrealizedPnL: unrealizedPnL.roundedWithoutFraction(),
                unrealizedPnLPercentage: unrealizedPnLPercentage ?? 0
            ))
        }
        return result.filter { $0.qty != 0 }
    }
    
}

extension Decimal {
    func roundedWithoutFraction() -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, 0, .plain)
        return result
    }
}
