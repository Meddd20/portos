//
//  Holding+Logic.swift
//  portos
//
//  Created by Medhiko Biraja on 15/08/25.
//

import Foundation

extension Holding {
    func applyBuyTransactions(buyQty: Decimal, buyPrice: Decimal, tradeCurrency: Currency, exchangeRate: Decimal) throws {
        guard quantity > 0 else { return }
        
        let oldQty = self.quantity
        let oldCost = oldQty * self.averagePricePerUnit
        
        let newCost = buyQty * buyPrice
        let newQty = oldQty + quantity
        let newAvgPrice = (oldCost + newCost) / newQty
        
        self.quantity = newQty
        self.averagePricePerUnit = newAvgPrice
        self.updatedAt = .now
    }
    
    func applySellTransactions(sellQty: Decimal, sellPrice: Decimal, tradeCurrency: Currency, exchangeRate: Decimal) throws {
        guard sellQty > 0 else { return }
        guard sellQty <= self.quantity else { return }
        
        // Information that good to know, personally doesn't have an idea where to use or store so just keep it there
        let sellRealizedValue = sellQty * sellPrice
        let costBasis = self.averagePricePerUnit * sellQty
        let realizedPnL = sellRealizedValue - costBasis
        
        self.quantity -= sellQty
        self.updatedAt = .now
    }
}
