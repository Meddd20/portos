//
//  TransferTransactionRepository.swift
//  portos
//
//  Created by Medhiko Biraja on 22/08/25.
//

import Foundation
import SwiftData

class TransferTransactionRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllTransferTransactions() throws -> [TransferTransaction] {
        let descriptor = FetchDescriptor<TransferTransaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func getTransferTransaction(id: UUID) throws -> TransferTransaction? {
        var descriptor = FetchDescriptor<TransferTransaction>(
            predicate: #Predicate<TransferTransaction> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func addTransferTransaction(_ transferTransaction: TransferTransaction) {
        modelContext.insert(transferTransaction)
        try? modelContext.save()
    }
    
    func editTransferTransaction(id: UUID, apply changes: (TransferTransaction) throws -> Void) throws {
        var descriptor = FetchDescriptor<TransferTransaction>(
            predicate: #Predicate<TransferTransaction> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        guard let transferTransaction = try modelContext.fetch(descriptor).first else { return }
        
        try changes(transferTransaction)
        try modelContext.save()
    }
    
    func deleteTransferTransaction(id: UUID) throws {
        var descriptor = FetchDescriptor<TransferTransaction>(
            predicate: #Predicate<TransferTransaction> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        guard let transferTransaction = try modelContext.fetch(descriptor).first else { return }
        modelContext.delete(transferTransaction)
        try modelContext.save()
    }
}
