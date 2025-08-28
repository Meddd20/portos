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
    @Published var allTransactions: [Transaction] = []
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
            let portfolio = historyTransactions.first?.portfolio
            
            let allTsx = try transactionService.getAllTransactions(portfolioId: nil)
            let portfolioTsx: [Transaction] = allTsx.filter { $0.portfolio.id == portfolio?.id && $0.holding.id == holding.id }
            let groupTransferTsx = Set(portfolioTsx.compactMap(\.transferGroupId))
            let unified = allTsx.filter { tsx in
                (tsx.portfolio.id == portfolio?.id && tsx.holding.id == holding.id ) ||
                (tsx.transferGroupId != nil && groupTransferTsx.contains(tsx.transferGroupId!))
            }
                .uniqued(by: \.id)
                .sorted { $0.date > $1.date }

            self.allTransactions = unified
            self.transactionSectionedByDate = groupTransactionsByDate(transactions: unified)

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
