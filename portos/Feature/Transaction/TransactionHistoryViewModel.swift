//
//  TransactionHistoryViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation

class TransactionHistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var transactionSectionedByDate: [TransactionSection] = []
    @Published var historyOf: String = "All"
    private var transactionService: TransactionService
    let portfolio: Portfolio?
    
    init(di: AppDI, portfolio: Portfolio? = nil) {
        self.transactionService = di.transactionService
        self.portfolio = portfolio
        
        if portfolio != nil {
            historyOf = portfolio?.name ?? "all".localized
        }
    }
    
    func getTransactions() {
        do {
            let allTsx = try transactionService.getAllTransactions(portfolioId: nil)
            
            let portfolioTsx: [Transaction]
            if let currentPortfolio = portfolio {
                portfolioTsx = allTsx.filter { $0.portfolio.id == currentPortfolio.id }
            } else {
                portfolioTsx = allTsx
            }
            
            let groupTransferTsx = Set(portfolioTsx.compactMap(\.transferGroupId))
            
            if let portfolio {
                let unified = allTsx.filter { tsx in
                    (tsx.portfolio.id == portfolio.id) ||
                    (tsx.transferGroupId != nil && groupTransferTsx.contains(tsx.transferGroupId!))
                }
                    .uniqued(by: \.id)
                    .sorted { $0.date > $1.date }

                self.transactions = unified
                self.transactionSectionedByDate = groupTransactionsByDate(transactions: unified)
            } else {
                let unified = allTsx
                self.transactions = unified
                self.transactionSectionedByDate = groupTransactionsByDate(transactions: unified)
            }
            
        } catch {
            print(error.localizedDescription)
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
}

struct TransactionSection: Identifiable {
    let id = UUID()
    let date: Date
    let transactions: [Transaction]
}

extension Array {
    func uniqued<ID: Hashable>(by keyPath: KeyPath<Element, ID>) -> [Element] {
        var seen = Set<ID>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
