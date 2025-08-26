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
    
    private let transactionRepository: TransactionRepository
    private let transactionService: TransactionService
    private let holdingService: HoldingService
    let portfolioService: PortfolioService
    
    let asset: Asset
    let transferMode: TransferMode
    let holding: Holding?
    let transaction: Transaction?
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode, holding: Holding? = nil, transaction: Transaction? = nil) {
        self.holdingService = di.holdingService
        self.transactionService = di.transactionService
        self.portfolioService = di.portfolioService
        self.transactionRepository = di.transactionRepository
        self.asset = asset
        self.transferMode = transferMode
        self.holding = holding
        self.transaction = transaction
        
        guard let holding else { return }
        let recap = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
        accountPositions = recap?.accounts ?? []
        portfolioTransferFrom = holding.portfolio
        
        if transaction != nil {
            amountText = transaction?.quantity.description ?? ""
            platform = transaction?.app
            
            guard let transferGroupId = transaction?.transferGroupId else { return }

            var transactionTo = try? self.transactionRepository.getDetailTransferTransaction(transferGroupId: transferGroupId, transactionType: TransactionType.allocateIn)
            
            portfolioTransferTo = transactionTo?.portfolio
            isDataFilled = false
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
    
    @MainActor func proceedTransaction() {
        guard isDataFilled else { return }
        if transferMode == .transferToPortfolio {
            addTransferTransaction()
        } else {
            editTransferTransaction()
        }
    }
    
    @MainActor func addTransferTransaction() {
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
    
    @MainActor
    func editTransferTransaction() {
        do {
            guard transaction?.id != nil, isDataFilled, let platform = platform, let amount = amount, let portfolioTransferTo = portfolioTransferTo else { return }
            
            print("lewat?")
            
            try transactionService.editTransferTransaction(
                transferTransactionId: transaction?.id ?? UUID(),
                amount: amount,
                portfolioDestination: portfolioTransferTo,
                platform: platform,
                asset: asset
            )
            
//            try transactionService.debugEditTransferTransaction(
//                transferTransactionId: transaction?.id ?? UUID(),
//                amount: amount,
//                portfolioDestination: portfolioTransferTo,
//                platform: platform,
//                asset: asset
//            )
            
            print("masuk?")
            
            didFinishTransaction = true
        } catch {
            print(error.localizedDescription)
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
            let amountChange = amount == transaction?.quantity
            let platformChange = platform == transaction?.app
            let portfolioChange = portfolioTransferTo == transaction?.portfolio
            isDataFilled = amountChange || platformChange || portfolioChange
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
