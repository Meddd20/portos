//
//  TradeTransactionViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 21/08/25.
//

import SwiftUI

@MainActor
class TradeTransactionViewModel: ObservableObject {
    @Published var amountText: String = "" {
        didSet { updateIsDataFilled() }
    }
    @Published var priceText: String = "" {
        didSet { updateIsDataFilled() }
    }
    @Published var platform: AppSource? {
        didSet { updateIsDataFilled() }
    }
    @Published var portfolio: Portfolio? {
        didSet { updateIsDataFilled() }
    }
    
    @Published var purchaseDate: Date = Date()
    @Published var isDataFilled: Bool = false
    @Published var didFinishTransaction = false
    
    var amount: Decimal {
        Decimal(string: amountText) ?? 0
    }
    
    var price: Decimal {
        Decimal(string: priceText) ?? 0
    }
    
    let portfolioService: PortfolioService
    private let transactionService: TransactionService
    private let appSourceRepository: AppSourceRepository
    private let transactionId: UUID?
    private var transaction: Transaction?
    let transactionMode: TransactionMode
    let asset: Asset
    let currentPortfolioAt: Portfolio?
    
    @Published var platforms: [AppSource] = []
    @Published var portfolios: [Portfolio] = []
    
    init(
        di: AppDI,
        transactionMode: TransactionMode,
        transactionId: UUID? = nil,
        asset: Asset,
        currentPortfolioAt: Portfolio?
    ) {
        self.portfolioService = di.portfolioService
        self.transactionService = di.transactionService
        self.appSourceRepository = di.appSourceRepository
        self.transactionMode = transactionMode
        self.transactionId = transactionId
        self.asset = asset
        self.currentPortfolioAt = currentPortfolioAt
        self.portfolio = currentPortfolioAt
    }
        
    @MainActor
    func loadData() {
        do {
            platforms = try appSourceRepository.getAllAppSource()
            portfolios = try portfolioService.getAllPortfolios()
                        
            for p in platforms {
                print(p.name)
            }
            
            for po in portfolios {
                print(po.name)
            }
        } catch {
            print("Error fetching apps: \(error)")
            return
        }
    }
    
    func proceedTransaction() {
        guard isDataFilled else { return }
        
        switch transactionMode {
        case .buy:
            addBuyTransaction()
        case .liquidate:
            addLiquidateTransaction()
        case .editBuy, .editLiquidate:
            editTransaction()
        }
    }
    
    func addBuyTransaction() {
        do {
            guard isDataFilled, let platform = platform, let portfolio = portfolio else { return }
            
            if isDataFilled {
                try transactionService.recordBuyTransaction(
                    appSource: platform,
                    asset: asset,
                    portfolio: portfolio,
                    quantity: amount,
                    price: price,
                    date: purchaseDate,
                    tradeCurrency: .usd,
                    exchangeRate: 16586
                )
                
                didFinishTransaction = true
            }
        } catch {
            print("Error adding buy transaction: \(error)")
            return
        }
    }
    
    func addLiquidateTransaction() {
        do {
//            try transactionService.recordSellTransaction(
//                appSource: platform,
//                asset: <#T##Asset#>,
//                portfolio: portfolio,
//                holding: <#T##Holding#>,
//                quantity: amount,
//                sellPrice: price,
//                date: purchaseDate,
//                tradeCurrency: <#T##Currency#>,
//                exchangeRate: <#T##Decimal#>
//            )
        } catch {
            print("Error adding liquidate transaction: \(error)")
            return
        }
    }
    
    func editTransaction() {
        do {
//            try transactionService.editTransaction(
//                transactionId: transactionId,
//                amount: amount,
//                price: price,
//                platform: platform,
//                asset: <#T##Asset#>,
//                portfolio: portfolio,
//                date: purchaseDate
//            )
        } catch {
            print("Error editing transaction: \(error)")
            return
        }
    }
    
    func getDetailTransaction() {
        guard let transactionId, transactionMode.isEdit else { return }
        
        do {
            transaction = transactionService.getDetailTransaction(transactionId: transactionId)
            
//            MainActor.run {
//                if let transaction {
//                    self.amountText = transaction.quantity.description
//                    self.priceText = transaction.price.description
//                    self.platform = transaction.app
//                    self.portfolio = transaction.portfolio
//                    self.purchaseDate = transaction.date
//                }
//            }
        } catch {
            print("Error loading transaction: \(error)")
            return
        }
    }
    
    private func updateIsDataFilled() {
        switch transactionMode {
        case .buy:
            isDataFilled = amount > 0 && price > 0 && platform != nil && portfolio != nil
        case .liquidate, .editBuy, .editLiquidate:
            let amountChange = amount == transaction?.quantity
            let priceChange = price == transaction?.price
            let platformChange = platform == transaction?.app
            let portfolioChange = portfolio == transaction?.portfolio
            let dateChange = purchaseDate == transaction?.date
            isDataFilled = amountChange || priceChange || platformChange || portfolioChange || dateChange
        }
    }
    
}
