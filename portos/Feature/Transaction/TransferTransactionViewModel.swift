//
//  TransferTransactionViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 22/08/25.
//

import SwiftUI

class TransferTransactionViewModel: ObservableObject {
    @Published var amountText = "" {
        didSet { }
    }
    @Published var portfolioTransferFrom: Portfolio?
    @Published var portfolioTransferTo: Portfolio?
    @Published var platform: AppSource?
    @Published var isDataFilled: Bool = false
    
    private let transactionService: TransactionService
    private let transferTransactionRepository: TransferTransactionRepository
    private var transaction: Transaction?
    private var transferTransaction: TransferTransaction?
    
    private let transactionId: UUID?
    var platforms: [AppSource] = []
    var portfolios: [Portfolio] = []
    let asset: Asset
    let transferMode: TransferMode
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode, transactionId: UUID? = nil) {
        self.asset = asset
        self.transferMode = transferMode
        self.transactionId = transactionId
        transactionService = di.transactionService
        transferTransactionRepository = di.transferTransactionRepository
    }
    
    var amount: Decimal? {
        Decimal(string: amountText) ?? 0
    }
    
    func getDetailTransaction() async {
        guard let transactionId, transferMode.isEdit else { return }
        
        do {
            transferTransaction = try transferTransactionRepository.getTransferTransaction(id: transactionId)
            
            await MainActor.run {
                if let transferTransaction {
                    self.amountText = transferTransaction.amount.description
                    self.portfolioTransferFrom = transferTransaction.fromTransaction.portfolio
                    self.portfolioTransferTo = transferTransaction.toTransaction.portfolio
                    self.platform = transferTransaction.platform
                }
            }
        } catch {
            print("Error loading transaction: \(error)")
            return
        }
    }
    
//    private func updateFilledData() {
//        switch transferMode {
//        case .transferToPortfolio:
//            isDataFilled = amount != nil
//        }
//    }
}

enum TransferMode {
    case transferToPortfolio
    case editTransferTransaction
    
    var isEdit: Bool {
        switch self {
        case .editTransferTransaction: return true
        default: return false
        }
    }
}
