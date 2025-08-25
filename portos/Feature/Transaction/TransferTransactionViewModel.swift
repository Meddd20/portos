//
//  TransferTransactionViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 22/08/25.
//

import SwiftUI

class TransferTransactionViewModel: ObservableObject {
    @Published var amountText = "" {
        didSet { updateIsDataFilled() }
    }
    @Published var portfolioTransferFrom: Portfolio?
    @Published var portfolioTransferTo: Portfolio? {
        didSet { updateIsDataFilled() }
    }
    @Published var platform: AppSource? {
        didSet { updateIsDataFilled() }
    }
    @Published var isDataFilled: Bool = false
    @Published var didFinishTransaction = false
    @Published var accountPositions: [AccountPosition] = []
    @Published var platforms: [AppSource] = []
    @Published var portfolios: [Portfolio] = []
    @Published var maxAmountPerAccount: Decimal? = 0
    
    private let transactionService: TransactionService
    private let transferTransactionRepository: TransferTransactionRepository
    private let holdingService: HoldingService
    let portfolioService: PortfolioService
    private var transferTransaction: TransferTransaction?
    
    let asset: Asset
    let transferMode: TransferMode
    let holding: Holding?
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode, holding: Holding? = nil, transferTransaction: TransferTransaction? = nil) {
        self.holdingService = di.holdingService
        self.transactionService = di.transactionService
        self.portfolioService = di.portfolioService
        self.transferTransactionRepository = di.transferTransactionRepository
        self.asset = asset
        self.transferMode = transferMode
        self.holding = holding
        self.transferTransaction = transferTransaction
        
        guard let holding else { return }
        let recap = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
        accountPositions = recap?.accounts ?? []
        portfolioTransferFrom = holding.portfolio
        
        if transferTransaction != nil {
            amountText = transferTransaction?.amount.description ?? ""
            portfolioTransferFrom = transferTransaction?.fromTransaction.portfolio
            portfolioTransferTo = transferTransaction?.toTransaction.portfolio
            platform = transferTransaction?.platform
        }
    }
    
    var amount: Decimal? {
        Decimal(string: amountText) ?? 0
    }
        
    func loadData() {
        do {
            portfolios = try portfolioService.getAllPortfolios()
            portfolios = portfolios.filter { $0.id != holding?.portfolio.id }
            
            platforms = accountPositions.map { $0.appSource }
                
        } catch {
            print("Error fetching apps: \(error)")
            return
        }
    }
    
    func proceedTransaction() {
        guard isDataFilled else { return }
        
        if transferMode == .transferToPortfolio {
            addTransferTransaction()
        } else {
            editTransferTransaction()
        }
    }
    
    func addTransferTransaction() {
        do {
            guard isDataFilled, let platform = platform, let amount = amount, let portfolioTransferFrom = portfolioTransferFrom, let holding = holding, let portfolioTransferTo = portfolioTransferTo else { return }
            
            try transactionService.recordTransferTransaction(
                appSource: platform,
                asset: asset,
                holding: holding,
                currentPortfolio: portfolioTransferFrom,
                quantity: amount,
                destinationPortfolio: portfolioTransferTo,
                date: .now,
                tradeCurrency: .usd,
                exchangeRate: 16716
            )
            
            didFinishTransaction = true
        } catch {
            print("Error adding transfer transaction: \(error)")
            return
        }
    }
    
    func editTransferTransaction() {
        guard transferTransaction != nil, let portfolioTransferTo = portfolioTransferTo, let platform = platform else { return }
        
        do {
            try transactionService.editTransferTransaction(
                transferTransactionId: transferTransaction?.id ?? UUID(),
                amount: amount ?? 0,
                portfolioDestination: portfolioTransferTo,
                platform: platform,
                asset: asset
            )
            
            didFinishTransaction = true
        } catch {
            print("Error editing transfer transaction: \(error)")
            return
        }
    }
    
    private func updateIsDataFilled() {
        if let platform, amountText == "", portfolioTransferTo != nil {
            getMaxAmountInHoldingPlatformBased(platform: platform)
        }
        
        getMaxAmountInHoldingPlatformBased(platform: platform)
                
        switch transferMode {
        case .transferToPortfolio:
            isDataFilled = platform != nil && amountText != "" && portfolioTransferTo != nil
        
        case .editTransferTransaction:
            let amountChange = amount == transferTransaction?.amount
            let portfolioDestinationChange = portfolioTransferTo != transferTransaction?.toTransaction.portfolio
            let platformChange = platform == transferTransaction?.toTransaction.app
            
            isDataFilled = amountChange || portfolioDestinationChange || platformChange
        }
    }
    
    func getMaxAmountInHoldingPlatformBased(platform: AppSource?) {
        let accountPosition: AccountPosition? = accountPositions.first(where: { $0.appSource == platform })
        maxAmountPerAccount = accountPosition?.qty
        
        if amountText == "" {
            amountText = maxAmountPerAccount?.description ?? "0"
        }
    }
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
