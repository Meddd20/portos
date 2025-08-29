//
//  PortfolioViewModel.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import Foundation
import SwiftData

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var portfolios: [Portfolio] = []
    @Published var error: String?
    @Published var portfolioValue: Int = 0
    @Published var profitAmount: Int = 0
    @Published var growthRate: String = ""
    @Published var actual: [DataPoint] = []
    @Published var projection: [DataPoint] = []
    @Published var isLoading = false
    @Published var actualSeries: [DataPoint] = []
    @Published var projectionSeries: [DataPoint] = []
    
    private let base = "http://34.171.18.14:3000/historical/price"
        private let decoder: JSONDecoder = {
            let d = JSONDecoder()
            let f = DateFormatter()
            f.calendar = .init(identifier: .gregorian)
            f.locale   = .init(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd"
            d.dateDecodingStrategy = .formatted(f)
            return d
        }()

    @Published var assets: [AssetGroup] = []
    
    @Published var portfolioOverview: PortfolioOverview = PortfolioOverview(portfolioValue: "default", portfolioGrowthRate: "default", portfolioProfitAmount: "default", groupItems: [])
    
    private let service: PortfolioService
    private let localizationManager = LocalizationManager.shared

    init(di: AppDI) {
        self.service = di.portfolioService
        getPortfolioOverview()
    }

    func load() {
        do {
            portfolios = try service.getAllPortfolios()
        }
        catch { self.error = error.localizedDescription }
    }
    
    func getPortfolioOverview(portfolioName: String? = nil) {
        do {
            if portfolioName == nil {
                portfolioOverview = try service.getPortfolioOverview()
                assets = portfolioOverview.groupItems
            } else {
                portfolioOverview = try service.getPortfolioOverviewByGoal(portfolioName!)
            }
        }
        catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Currency Conversion Methods
    
    func getPortfolioOverviewWithCurrencyConversion(portfolioName: String? = nil) {
        let targetCurrency = localizationManager.currentCurrency
        
        if portfolioName == nil {
            // Get overall portfolio overview and convert
            getPortfolioOverviewWithConversion(targetCurrency: targetCurrency)
        } else {
            // Get specific portfolio overview and convert
            getPortfolioOverviewByGoalWithConversion(portfolioName: portfolioName!, targetCurrency: targetCurrency)
        }
    }
    
    private func getPortfolioOverviewWithConversion(targetCurrency: Currency) {
        do {
            let originalOverview = try service.getPortfolioOverview()
            
            let convertedOverview = try convertPortfolioOverviewToCurrency(originalOverview, targetCurrency: targetCurrency)
            portfolioOverview = convertedOverview
            assets = convertedOverview.groupItems
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func getPortfolioOverviewByGoalWithConversion(portfolioName: String, targetCurrency: Currency) {
        do {
            let originalOverview = try service.getPortfolioOverviewByGoal(portfolioName)
            
            let convertedOverview = try convertPortfolioOverviewToCurrency(originalOverview, targetCurrency: targetCurrency)
            portfolioOverview = convertedOverview
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func convertPortfolioOverviewToCurrency(_ overview: PortfolioOverview, targetCurrency: Currency) throws -> PortfolioOverview {
        var convertedGroupItems: [AssetGroup] = []
        var totalConvertedValue: Decimal = Decimal(0)
        var totalConvertedProfit: Decimal = Decimal(0)
        
        // Convert each group
        for group in overview.groupItems {
            let convertedGroup = try convertAssetGroupToCurrency(group, targetCurrency: targetCurrency)
            convertedGroupItems.append(convertedGroup)
            
            // Calculate group total directly from the converted assets
            var groupTotal: Decimal = Decimal(0)
            for asset in group.assets {
                if let holding = asset.holding {
                    let assetCurrency = holding.asset.currency
                    let originalValue = asset.value ?? "0"
                    
                    if let numericValue = parseFormattedValue(originalValue) {
                        let conversionRate = getCurrencyRate(from: assetCurrency, to: targetCurrency)
                        
                        let convertedValue: Decimal
                        if assetCurrency == .idr && targetCurrency == .usd {
                            convertedValue = numericValue / Decimal(conversionRate)
                        } else if assetCurrency == .usd && targetCurrency == .idr {
                            convertedValue = numericValue * Decimal(conversionRate)
                        } else {
                            convertedValue = numericValue
                        }
                        
                        groupTotal += convertedValue
                    }
                }
            }
            
            totalConvertedValue += groupTotal
        }
        
        // Calculate total profit (this is a simplified approach)
        if let originalProfit = parseFormattedValue(overview.portfolioProfitAmount ?? "0") {
            totalConvertedProfit = originalProfit
        }
        
        let finalPortfolioValue = formatCurrencyValue(totalConvertedValue, currency: targetCurrency)
        let finalProfitAmount = formatCurrencyValue(totalConvertedProfit, currency: targetCurrency)
        
        // Create new PortfolioOverview with converted values
        return PortfolioOverview(
            portfolioValue: finalPortfolioValue,
            portfolioGrowthRate: overview.portfolioGrowthRate,
            portfolioProfitAmount: finalProfitAmount,
            groupItems: convertedGroupItems
        )
    }
    
    private func convertAssetGroupToCurrency(_ group: AssetGroup, targetCurrency: Currency) throws -> AssetGroup {
        var convertedAssets: [AssetItem] = []
        var convertedGroupTotal: Decimal = Decimal(0)
        
        // Convert each asset in the group
        for asset in group.assets {
            let convertedAsset = try convertAssetItemToCurrency(asset, targetCurrency: targetCurrency)
            convertedAssets.append(convertedAsset)
            
            // Get the numeric value directly from the converted asset
            // Don't parse the formatted string back - use the actual converted value
            if let holding = asset.holding {
                let assetCurrency = holding.asset.currency
                let originalValue = asset.value ?? "0"
                
                if let numericValue = parseFormattedValue(originalValue) {
                    let conversionRate = getCurrencyRate(from: assetCurrency, to: targetCurrency)
                    
                    // Calculate converted value directly
                    let convertedValue: Decimal
                    if assetCurrency == .idr && targetCurrency == .usd {
                        convertedValue = numericValue / Decimal(conversionRate)
                    } else if assetCurrency == .usd && targetCurrency == .idr {
                        convertedValue = numericValue * Decimal(conversionRate)
                    } else {
                        convertedValue = numericValue
                    }
                    
                    convertedGroupTotal += convertedValue
                }
            }
        }
        
        let formattedTotal = formatCurrencyValue(convertedGroupTotal, currency: targetCurrency)
        
        // Create new AssetGroup with converted values
        return AssetGroup(
            name: group.name,
            value: formattedTotal,
            assets: convertedAssets
        )
    }
    
    private func convertAssetItemToCurrency(_ asset: AssetItem, targetCurrency: Currency) throws -> AssetItem {
        guard let holding = asset.holding else {
            return asset
        }
        
        let assetCurrency = holding.asset.currency
        let originalValue = asset.value ?? "0"
        
        // If currencies are the same, no conversion needed
        if assetCurrency == targetCurrency {
            return asset
        }
        
        // Parse the original value
        guard let numericValue = parseFormattedValue(originalValue) else {
            return asset
        }
        
        // Get conversion rate
        let conversionRate = getCurrencyRate(from: assetCurrency, to: targetCurrency)
        
        // Convert the value based on conversion direction
        let convertedValue: Decimal
        if assetCurrency == .idr && targetCurrency == .usd {
            // IDR to USD: divide by rate (e.g., 16586 IDR / 16586 = 1 USD)
            convertedValue = numericValue / Decimal(conversionRate)
        } else if assetCurrency == .usd && targetCurrency == .idr {
            // USD to IDR: multiply by rate (e.g., 1 USD * 16586 = 16586 IDR)
            convertedValue = numericValue * Decimal(conversionRate)
        } else {
            // Same currency or unexpected combination
            convertedValue = numericValue
        }
        
        // Create new AssetItem with converted value
        return AssetItem(
            holding: asset.holding,
            name: asset.name,
            value: formatCurrencyValue(convertedValue, currency: targetCurrency),
            growthRate: asset.growthRate,
            profitAmount: asset.profitAmount,
            quantity: asset.quantity
        )
    }
    
    // Cache for exchange rates to avoid multiple API calls
    private var exchangeRateCache: [String: Double] = [:]
    
    // Function to clear cache (useful when switching currencies)
    func clearExchangeRateCache() {
        exchangeRateCache.removeAll()
    }
    
    private func getCurrencyRate(from fromCurrency: Currency, to toCurrency: Currency) -> Double {
        // Create cache key
        let cacheKey = "\(fromCurrency.rawValue)_\(toCurrency.rawValue)"
        
        // Check cache first
        if let cachedRate = exchangeRateCache[cacheKey] {
            return cachedRate
        }
        
        // If currencies are the same, return 1.0 and cache it
        if fromCurrency == toCurrency {
            exchangeRateCache[cacheKey] = 1.0
            return 1.0
        }
        
        // Use fallback rate for better performance (temporary solution)
        let fallbackRate: Double
        if fromCurrency == .usd && toCurrency == .idr {
            fallbackRate = 16586.0
        } else if fromCurrency == .idr && toCurrency == .usd {
            fallbackRate = 16586.0
        } else {
            fallbackRate = 1.0
        }
        
        // Cache the fallback rate
        exchangeRateCache[cacheKey] = fallbackRate
        
        // Note: API calls are disabled for performance
        // Uncomment the code below if you want to use live rates
        /*
        // Use semaphore to make async call synchronous (temporary solution)
        let semaphore = DispatchSemaphore(value: 0)
        var rate: Double = 1.0
        
        ExchangeRateService.getConversionRate(from: fromCurrency, to: toCurrency) { result in
            switch result {
            case .success(let conversionRate):
                rate = conversionRate
            case .failure(_):
                rate = fallbackRate
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return rate
        */
        
        return fallbackRate
    }
    
    private func formatCurrencyValue(_ value: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        
        if currency == .idr {
            // Indonesian format: use dots as thousands separator, comma as decimal
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = "."
            formatter.decimalSeparator = ","
        } else {
            // US format: use commas as thousands separator, dot as decimal
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
        }
        
        let number = NSDecimalNumber(decimal: value)
        let formattedNumber = formatter.string(from: number) ?? "\(value)"
        
        return "\(currency.symbol) \(formattedNumber)"
    }
    
    private func parseFormattedValue(_ valueString: String) -> Decimal? {
        // Remove currency symbols and spaces
        let cleanString = valueString.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        // Handle Indonesian number format: "2.431.764,7" (dots as thousands, comma as decimal)
        // Handle US number format: "2,431,764.7" (commas as thousands, dot as decimal)
        
        // First, try to detect if it's Indonesian format (contains dots and comma)
        if cleanString.contains(".") && cleanString.contains(",") {
            // Indonesian format: "2.431.764,7" → "2431764.7"
            let indonesianFormat = cleanString.replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")
            
            if let decimal = Decimal(string: indonesianFormat) {
                return decimal
            }
        }
        
        // Try parsing as-is first
        if let decimal = Decimal(string: cleanString) {
            return decimal
        }
        
        // If that fails, try removing all separators
        let withoutSeparators = cleanString.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        if let decimal = Decimal(string: withoutSeparators) {
            return decimal
        }
        
        // Last resort: try as Double
        if let double = Double(withoutSeparators) {
            return Decimal(double)
        }
        
        return nil
    }
    
    func deletePortfolio(id: UUID) {
        do {
            try service.delete(id: id)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    @MainActor
    func loadChartData(type: String = "CRYPTO", symbol: String = "WBTC-USD", range: String = "3m") async {
        isLoading = true; error = nil
        do {
            var comp = URLComponents(string: base)!
            comp.queryItems = [
                .init(name: "type", value: type),
                .init(name: "symbol", value: symbol),
                .init(name: "range",  value: range)
            ]
            let (data, resp) = try await URLSession.shared.data(from: comp.url!)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }

            let res = try decoder.decode(ChartAPIResponse.self, from: data)

            // map ke DataPoint untuk chart
            let actualPoints = res.data.points
                .map { DataPoint(date: stringToDate($0.date) ?? .now, value: $0.close) }
                .sorted { $0.date < $1.date }

            self.actual = actualPoints
            self.projection = makeProjection(from: actualPoints) // boleh kosongkan kalau tak perlu
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    private func makeProjection(from actual: [DataPoint],
                                months: Int = 12,
                                monthlyReturn: Double = 0.01) -> [DataPoint] {
        guard let last = actual.last else { return [] }
        var v = last.value
        var d = last.date
        var out: [DataPoint] = []
        for _ in 0..<months {
            d = Calendar.current.date(byAdding: .month, value: 1, to: d) ?? d
            v *= (1 + monthlyReturn)
            out.append(DataPoint(date: d, value: v))
        }
        return out
    }

    @MainActor
    func refreshMarketValues() {
        isLoading = true
        error = nil
        actualSeries = []
        
        let items = portfolioOverview.groupItems.flatMap(\.assets)
        fetchSequential(items: items, index: 0, acc: [:])

    }
    
    // acc = accumulator ==> [id: value], [id2: value2]
    @MainActor
    private func fetchSequential(items: [AssetItem],
                                 index: Int,
                                 acc: [Date: Double]) {
        var acc = acc
        if index >= items.count {
            self.actualSeries = acc
                .map { DataPoint(date: $0.key, value: $0.value) }
                .sorted { $0.date < $1.date }
            
            self.calculateProjection()
            self.isLoading = false
            return
        }

        let item = items[index]

        guard let h = item.holding else {
            fetchSequential(items: items, index: index+1, acc: acc)
            return
        }

        let assetId: String = h.asset.assetId
        let qty: Decimal = item.holding?.quantity ?? 0
        let qtyDouble = NSDecimalNumber(decimal: qty).doubleValue
        var assetTypeApi: String = ""
        
        
        switch h.asset.assetType {
        case .Stocks, .StocksId: assetTypeApi = "STOCK"
        case .Crypto:            assetTypeApi = "CRYPTO"
        default:
            fetchSequential(items: items, index: index + 1, acc: acc)
            return
        }
        
        let symbol: String = h.asset.yTicker ?? ""
        let range: String = "5y"
        
        ApiService.getChartDataTimeseries(type: assetTypeApi, symbol: symbol, range: range) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let res):
                    var acc2 = acc
                    for p in res.data.points {
                        let dateStr = self.stringToDate(p.date)
                        let key = self.startOfMonth(dateStr ?? Date())
                        let v   = p.close * qtyDouble
                        acc2[key, default: 0] += v
                    }

                    self.fetchSequential(items: items, index: index + 1, acc: acc2)
                case .failure(let err):
                    self.fetchSequential(items: items, index: index + 1, acc: acc)
                }
            }
        }
    }
    
    func calculateProjection() {
        // Panggil helper function
        projectionSeries = MonteCarloProjectionHelper.calculateProjection(from: actualSeries)
    }
    
    // Atau dengan custom config
    func calculateProjectionWithCustomConfig() {
        let config = MonteCarloConfig(
            numberOfSimulations: 2000,
            projectionDays: 60,
            confidenceLevel: 0.90
        )
        
        projectionSeries = MonteCarloProjectionHelper.calculateProjection(
            from: actualSeries,
            config: config
        )
    }
    
    func getPlatforms(transactions: [Transaction]) -> String {
        let unique = Set(transactions.map { $0.app.name })
        return unique.sorted().joined(separator: ", ")
    }

    func formatDouble(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func startOfMonth(_ date: Date, _ cal: Calendar = .current) -> Date {
        let c = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: c) ?? date
    }
    
    func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }
}
