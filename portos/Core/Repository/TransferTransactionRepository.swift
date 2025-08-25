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
    
    @MainActor
    func deleteTransferTransaction(id: UUID) throws {
        var fd = FetchDescriptor<TransferTransaction>(
            predicate: #Predicate<TransferTransaction> { $0.id == id }
        )
        fd.fetchLimit = 1

        guard let tt = try modelContext.fetch(fd).first else { return }

        // Simpan ref kuat ke anak-anak (jangan akses tt lagi setelah delete)
        let fromTx = tt.fromTransaction
        let toTx   = tt.toTransaction

        // 1) Putus backref di kedua leg (kunci agar graph tidak ambigu)
        fromTx.transferTransaction = nil
        toTx.transferTransaction   = nil

        // 2) Hapus kedua leg dulu (jangan rely on cascade karena backref tunggal)
        modelContext.delete(fromTx)
        modelContext.delete(toTx)

        // 3) Terakhir, hapus parent transfer
        modelContext.delete(tt)

        try modelContext.save()
    }
}
