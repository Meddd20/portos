//
//  DetailHoldingViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 24/08/25.
//

import Foundation

@MainActor
class DetailHoldingViewModel: ObservableObject {
    @Published var holdingAssetDetail: PortfolioAssetPosition?
    @Published var accountPosition: [AccountPosition] = []
    @Published var historyTransactions: [Transaction] = []
    @Published var transactionSectionedByDate: [TransactionSection] = []
    let holding: Holding
    let holdingService: HoldingService
    let transactionService: TransactionService
    
    init(di: AppDI, holding: Holding) {
        self.holding = holding
        self.holdingService = di.holdingService
        self.transactionService = di.transactionService
    }
    
    func getHoldingAssetDetail() {
        holdingAssetDetail = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
        accountPosition = holdingAssetDetail?.accounts ?? []
    }
    
    func getTransactions() {
        do {
            historyTransactions = try transactionService.getHoldingTransactions(holdingId: holding.id)
            transactionSectionedByDate = groupTransactionsByDate(transactions: historyTransactions)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func deleteTransaction(transactionId: UUID) {
        do {
            try transactionService.deleteTransaction(transactionId: transactionId)
            getHoldingAssetDetail()
            getTransactions()
        } catch {
            print(error.localizedDescription)
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
}
