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

    
    @Published var portfolioOverview: PortfolioOverview = PortfolioOverview(portfolioValue: "default", portfolioGrowthRate: "default", portfolioProfitAmount: "default", groupItems: [])
    
    private let service: PortfolioService

    init(service: PortfolioService) {
        self.service = service
        self.getPortfolioOverview()
    }

    func load() {
        do {
            portfolios = try service.getAllPortfolios()
            print(portfolios.count)
        }
        catch { self.error = error.localizedDescription }
    }
    
    func getPortfolioOverview(portfolioName: String? = nil) {
        do {
            if portfolioName == nil {
                portfolioOverview = try service.getPortfolioOverview()
            } else {
                portfolioOverview = try service.getPortfolioOverviewByGoal(portfolioName!)
            }
        }
        catch {
            self.error = error.localizedDescription
        }
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
            print(actualPoints)
            isLoading = false
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
        let range: String = "1y"
        
        print("qty: \(qty)")
        
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
                        let vInt = Int(v)
                        acc2[key, default: 0] += v
                    }

                    print("Rate:", res.data)
                    self.fetchSequential(items: items, index: index + 1, acc: acc2)
                case .failure(let err):
                    print("Error:", err)
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
