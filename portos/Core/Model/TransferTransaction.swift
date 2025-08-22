//
//  TransferTransaction.swift
//  portos
//
//  Created by Medhiko Biraja on 22/08/25.
//

import Foundation
import SwiftData

@Model
final class TransferTransaction {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Decimal
    
    @Relationship(deleteRule: .cascade)
    var fromTransaction: Transaction
    
    @Relationship(deleteRule: .cascade)
    var toTransaction: Transaction
    
    var platform: AppSource
    
    init(date: Date, amount: Decimal, fromTransaction: Transaction, toTransaction: Transaction, platform: AppSource) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.fromTransaction = fromTransaction
        self.toTransaction = toTransaction
        self.platform = platform
    }
}
