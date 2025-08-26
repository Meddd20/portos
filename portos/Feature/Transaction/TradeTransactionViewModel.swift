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
    @Published var maxAmountPerAccount: Decimal? = 0
    
    @Published var rateUSD: Decimal?
    @Published var pricePlaceholder: String?
    
    var amount: Decimal {
        Decimal(string: amountText) ?? 0
    }
    
    var price: Decimal {
        Decimal(string: priceText) ?? 0
    }
    
    let portfolioService: PortfolioService
    private let transactionService: TransactionService
    private let holdingService: HoldingService
    private let appSourceRepository: AppSourceRepository
    private let transaction: Transaction?
    let transactionMode: TransactionMode
    let asset: Asset
    let currentPortfolioAt: Portfolio?
    let holding: Holding?
    
    @Published var platforms: [AppSource] = []
    @Published var portfolios: [Portfolio] = []
    @Published var accountPositions: [AccountPosition] = []
    
    init(
        di: AppDI,
        transactionMode: TransactionMode,
        transaction: Transaction? = nil,
        holding: Holding? = nil,
        asset: Asset,
        currentPortfolioAt: Portfolio?
    ) {
        self.portfolioService = di.portfolioService
        self.transactionService = di.transactionService
        self.appSourceRepository = di.appSourceRepository
        self.holdingService = di.holdingService
        self.transactionMode = transactionMode
        self.transaction = transaction
        self.holding = holding
        self.asset = asset
        self.currentPortfolioAt = currentPortfolioAt
        self.portfolio = currentPortfolioAt
        
        if transaction != nil {
            self.amountText = transaction?.quantity.description ?? ""
            self.priceText = transaction?.price.description ?? ""
            self.platform = transaction?.app
            self.portfolio = transaction?.portfolio
            self.purchaseDate = transaction?.date ?? .now
        }
        
        if transactionMode == .liquidate {
            guard let holding else { return }
                        
            let recap = try? holdingService.getHoldingAssetDetail(holdingId: holding.id)
            accountPositions = recap?.accounts ?? []
        }
        
        isDataFilled = false
    }
        
    func loadData() {
        do {
            if transactionMode == .buy || transactionMode == .editBuy {
                platforms = try appSourceRepository.getAllAppSource()
            } else {
                platforms = accountPositions.map { $0.appSource }
            }

            portfolios = try portfolioService.getAllPortfolios()

        } catch {
            print("Error fetching apps: \(error)")
            return
        }
    }
    
    func proceedTransaction() {
        guard isDataFilled else { return }
//        print(isDataFilled)
        
        switch transactionMode {
        case .buy:
            addBuyTransaction()
        case .liquidate:
            print("this right?")
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
            guard isDataFilled else { return }
            guard let platform = platform else { return }
            guard let portfolio = portfolio else { return }
            guard let holding = holding else { return }
                        
            try transactionService.recordSellTransaction(
                appSource: platform,
                asset: asset,
                portfolio: portfolio,
                holding: holding,
                quantity: amount,
                sellPrice: price,
                date: purchaseDate,
                tradeCurrency: .usd,
                exchangeRate: 16586
            )
                        
            didFinishTransaction = true
        } catch {
            print("Error adding liquidate transaction: \(error)")
            return
        }
    }
    
    func editTransaction() {
        do {
            guard transaction != nil, isDataFilled else { return }
            guard let platform = platform else { return }
            guard let portfolio = portfolio else { return }
            
            try transactionService.editTransaction(
                transactionId: transaction?.id ?? UUID(),
                amount: amount,
                price: price,
                platform: platform,
                asset: asset,
                portfolio: portfolio,
                date: purchaseDate
            )
            
            didFinishTransaction = true
        } catch {
            print("Error editing transaction: \(error)")
            return
        }
    }
            
    private func updateIsDataFilled() {
        if platform != nil && transactionMode != .buy {
            getMaxAmountInHoldingPlatformBased(platform: platform)
        }
                
        switch transactionMode {
        case .buy:
            isDataFilled = amount > 0 && price > 0 && platform != nil && portfolio != nil
        case .liquidate:
            isDataFilled = amount > 0 && price > 0 && platform != nil
        case .editBuy, .editLiquidate:
            let amountChange = amount == transaction?.quantity
            let priceChange = price == transaction?.price
            let platformChange = platform == transaction?.app
            let portfolioChange = portfolio == transaction?.portfolio
            let dateChange = purchaseDate == transaction?.date
            isDataFilled = amountChange || priceChange || platformChange || portfolioChange || dateChange
        }
        
        print("Final check - amount: \(amount), price: \(price), platform: \(platform?.name ?? "nil"), isDataFilled: \(isDataFilled)")
    }
    
    func getMaxAmountInHoldingPlatformBased(platform: AppSource?) {
        let accountPosition: AccountPosition? = accountPositions.first(where: { $0.appSource == platform })
        maxAmountPerAccount = accountPosition?.qty
        
        if amountText == "" {
            amountText = maxAmountPerAccount?.description ?? "0"
        }
    }
    
    @MainActor
    func getRate(currency: String) {
        ExchangeRateService.getRate(currency: currency) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let res):
                    self?.rateUSD = res.data
                    if self?.asset.currency == Currency.usd && self?.rateUSD != nil{
                        self?.priceText = formatDecimal((self?.asset.lastPrice ?? 1) * (self?.rateUSD! ?? 1)) ?? "0"
                    }
                    
                    print("Rate:", res.data)
                case .failure(let err):
                    print("Error:", err)
                }
            }
        }
    }
}
