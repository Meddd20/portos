//
//  TransactionRepository.swift
//  portos
//
//  Created by Medhiko Biraja on 14/08/25.
//

import Foundation
import SwiftData

class TransactionRepository {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func getAssetHoldingTransactions(holdingId: UUID) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction>{ $0.holding.id == holdingId },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func getDetailTransaction(id: UUID) throws -> Transaction? {
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.id == id }
        )
        
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func getDetailTransferTransaction(transferGroupId: UUID, transactionType: TransactionType) throws -> Transaction? {
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.transactionType == transactionType && $0.transferGroupId == transferGroupId }
        )
        descriptor.fetchLimit = 1
        
        return try modelContext.fetch(descriptor).first
    }
    
    func addTransaction(_ transaction: Transaction) {
        modelContext.insert(transaction)
        try? modelContext.save()
    }
    
    func editTransaction(id: UUID, apply changes: (Transaction) throws -> Void) throws {
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.id == id}
        )
        
        descriptor.fetchLimit = 1
        
        guard let transaction = try modelContext.fetch(descriptor).first else { return }
        
        try changes(transaction)
        transaction.updatedAt = .now
        try modelContext.save()
    }
    
    func deleteTransaction(id: UUID) throws {
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.id == id }
        )
        
        descriptor.fetchLimit = 1
        
        guard let transaction = try modelContext.fetch(descriptor).first else {
            return
        }
                
        modelContext.delete(transaction)
        try modelContext.save()
    }
}
