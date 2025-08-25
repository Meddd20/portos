//
//  TransactionHistoryViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation

class TransactionHistoryViewModel: ObservableObject {
    @Published var transactionSectionedByDate: [TransactionSection] = []
    @Published var historyOf: String = "All"
    private var transactionService: TransactionService
    private var transferTransactionRepository: TransferTransactionRepository
    let portfolio: Portfolio?
    
    init(di: AppDI, portfolio: Portfolio? = nil) {
        self.transactionService = di.transactionService
        self.transferTransactionRepository = di.transferTransactionRepository
        self.portfolio = portfolio
        
        if portfolio != nil {
            historyOf = portfolio?.name ?? "All"
        }
    }
    
    func getTransactions() {
        do {
            let transactions = try transactionService.getAllTransactions(portfolioId: portfolio?.id)
            print("transaction has \(transactions.count)")
            transactionSectionedByDate = groupTransactionsByDate(transactions: transactions)
        } catch {
            return
        }
    }
    
    private func groupTransactionsByDate(transactions: [Transaction]) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { tsx in
            Calendar.current.startOfDay(for: tsx.date)
        }
        
        return grouped.map { (date, tsx) in
            TransactionSection(date: date, transactions: tsx.sorted { $0.date > $1.date })
        }
        .sorted { $0.date > $1.date }
    }
    
    @MainActor func deleteTransaction(transactionId: UUID) {
        do {
            try transactionService.deleteTransaction(transactionId: transactionId)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor func deleteTransfer(transactionId: UUID) {
        try? transferTransactionRepository.deleteTransferTransaction(id: transactionId)
    }
}

struct TransactionSection: Identifiable {
    let id = UUID()
    let date: Date
    let transactions: [Transaction]
}
