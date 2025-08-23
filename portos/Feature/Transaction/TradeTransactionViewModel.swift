//
//  TradeTransactionViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 21/08/25.
//

import SwiftUI

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
    
    var platforms: [AppSource] = []
    var portfolios: [Portfolio] = []
    
    init(di: AppDI, transactionMode: TransactionMode, transactionId: UUID? = nil) {
        self.portfolioService = di.portfolioService
        self.transactionService = di.transactionService
        self.appSourceRepository = di.appSourceRepository
        self.transactionMode = transactionMode
        self.transactionId = transactionId
    }
        
    func loadData() async {
        do {
            platforms = try appSourceRepository.getAllAppSource()
            portfolios = try portfolioService.getAllPortfolios()
            
//            platforms = [
//                AppSource(name: "Bibit"),
//                AppSource(name: "Stockbit"),
//                AppSource(name: "Binance")
//            ]
//            
//            portfolios = [
//                Portfolio(
//                    name: "Retirement Fund",
//                    targetAmount: 1_000_000_000,
//                    targetDate: Date().addingTimeInterval(60*60*24*365),
//                    isActive: true,
//                    createdAt: Date(),
//                    updatedAt: Date()
//                ),
//                Portfolio(
//                    name: "Vacation Fund",
//                    targetAmount: 100_000_000,
//                    targetDate: Date().addingTimeInterval(60*60*24*180),
//                    isActive: true,
//                    createdAt: Date(),
//                    updatedAt: Date()
//                ),
//                Portfolio(
//                    name: "Education Fund",
//                    targetAmount: 500_000_000,
//                    targetDate: Date().addingTimeInterval(60*60*24*365*5),
//                    isActive: false,
//                    createdAt: Date(),
//                    updatedAt: Date()
//                )
//            ]
        } catch {
            print("Error fetching apps: \(error)")
            return
        }
    }
    
    func proceedTransaction() async {
        guard isDataFilled else { return }
        
        switch transactionMode {
        case .buy:
            await addBuyTransaction()
        case .liquidate:
            await addLiquidateTransaction()
        case .editBuy, .editLiquidate:
            await editTransaction()
        }
    }
    
    func addBuyTransaction() async {
        do {
            if isDataFilled {
//                try transactionService.recordBuyTransaction(
//                    appSource: platform ?? AppSource(name: "Unknown"),
//                    asset: <#T##Asset#>,
//                    portfolio: portfolio ?? Portfolio(name: "Unknown"),
//                    quantity: amount,
//                    price: price,
//                    date: purchaseDate,
//                    tradeCurrency: <#T##Currency#>,
//                    exchangeRate: <#T##Decimal#>
//                )
                
                didFinishTransaction = true
            }
        } catch {
            print("Error adding buy transaction: \(error)")
            return
        }
    }
    
    func addLiquidateTransaction() async {
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
    
    func editTransaction() async {
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
    
    func getDetailTransaction() async {
        guard let transactionId, transactionMode.isEdit else { return }
        
        do {
            transaction = transactionService.getDetailTransaction(transactionId: transactionId)
            
            await MainActor.run {
                if let transaction {
                    self.amountText = transaction.quantity.description
                    self.priceText = transaction.price.description
                    self.platform = transaction.app
                    self.portfolio = transaction.portfolio
                    self.purchaseDate = transaction.date
                }
            }
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
