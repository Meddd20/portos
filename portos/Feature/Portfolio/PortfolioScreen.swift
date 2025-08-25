//
//  PortfolioScreen.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

struct PortfolioScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.di) var di
    
    @StateObject private var viewModel: PortfolioViewModel
    
    init(service: PortfolioService) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(service: service))
    }

    @State private var selection: Portfolio?
    @State private var selectionID: UUID? = nil
    @State private var selectedIndex: Int = 0
    @State private var showingAdd = false
    @State private var items: [Holding] = []
    @State private var showTrade = false
    @State private var showTransactionHistory = false
    @State private var selectedHolding: Holding? = nil
    
    @Query(sort: \Portfolio.createdAt) var portfolios: [Portfolio]
    
    let sampleData = createSampleData()
    
    var body: some View {
        VStack(alignment: .center) {
            PickerSegmented(
                selectedIndex: $selectedIndex,
                titles: ["All"] + portfolios.map { $0.name },
                onChange: onPickerChange,
                onAdd: { showingAdd = true }
            )
            
            ScrollView {
                VStack(alignment: .center) {
                    Text("Rp \(viewModel.portfolioOverview.portfolioValue!)")
                        .padding(.top, 27)
                    HStack(alignment: .center) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 12))

                        Text("\(viewModel.portfolioOverview.portfolioGrowthRate!)%")
                            .font(.system(size: 16, weight: .regular))
                            .padding(.trailing, 14)

                        Text("Rp \(viewModel.portfolioOverview.portfolioProfitAmount!)")
                            .font(.system(size: 16, weight: .regular))
                    }
                    .foregroundColor(Color(red: 0.05, green: 0.6, blue: 0.11))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(red: 0.86, green: 0.92, blue: 0.86))
                    .cornerRadius(14)
                }
                
                InvestmentChartWithRange(projection: sampleData.projection, actual: sampleData.actual)
                
                HStack {
                    
                    CircleButton(systemName: "arrow.trianglehead.clockwise", title: "History") {
                        showTransactionHistory = true
                    }
                    .navigationDestination(isPresented: $showTransactionHistory) {
                        if selectedIndex == 0 {
                            TransactionHistoryView(di: di)
                        } else {
                            TransactionHistoryView(di: di, portfolio: portfolios[selectedIndex - 1])
                        }
                    }
                    
                    CircleButton(systemName: "plus", title: "Add") {
                        showTrade = true
                    }
                    .navigationDestination(isPresented: $showTrade) {
                        if selectedIndex == 0 {
                            SearchAssetView(di: di, currentPortfolioAt: nil)
                        } else {
                            SearchAssetView(di: di, currentPortfolioAt: portfolios[selectedIndex - 1])
                        }
                    }
                    
                    CircleButton(systemName: "ellipsis", title: "More", action: { print("more clicked") })
                }
                
                ForEach(viewModel.portfolioOverview.groupItems, id: \.id) { item in
                    HStack {
                        Text(item.name!)
                            .font(.system(size: 28))
                        Spacer()
                        VStack {
                            Text("Rp \(item.value!)")
                        }
                    }.padding(.top, 39)
                    
                    Divider().frame(height: 1)
                    
                    ForEach(item.assets, id: \.id) { asset in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(asset.name!)
                                    .font(.system(size: 20))
                                if (selectedIndex != 0) {
                                    Text(asset.quantity!)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Rp \(asset.value!)")
                                    .font(.system(size: 17))
                                Text("\(asset.growthRate!)%")
                                    .font(.system(size: 12))
                            }
                        }.padding(.top, 10)
                            .onTapGesture { selectedHolding =  asset.holding }
                            
                    }
                }
            }.scrollIndicators(.hidden)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .navigationDestination(isPresented: $showingAdd) {
            AddPortfolio(di: di)
        }
        .onAppear() {
            let name = (selectedIndex == 0) ? nil : portfolios[selectedIndex-1].name
            viewModel.getPortfolioOverview(portfolioName: name)
        }
        .navigationDestination(item: $selectedHolding) {holding in
            DetailHoldingView(holding: holding)
        }
    }

    private func onPickerChange() {
        let name = (selectedIndex == 0) ? nil : portfolios[selectedIndex-1].name
        viewModel.getPortfolioOverview(portfolioName: name)
    }
    
    // Projection: tren halus + gelombang
    func makeProjection(months: Int = 72, start: Double = 100) -> [DataPoint] {
        let startDate = Calendar.current.date(byAdding: .month, value: -(months-1), to: Date())!
        return (0..<months).map { i in
            let date = Calendar.current.date(byAdding: .month, value: i, to: startDate)!
            let trend  = Double(i) * 1.7
            let wave1  = sin(Double(i) * 0.45) * 6
            let wave2  = sin(Double(i) * 0.12 + 1.1) * 3
            let step   = (i % 9 == 0) ? 5.0 : 0.0
            return DataPoint(date: date, value: max(1, start + trend + wave1 + wave2 + step))
        }
    }

    // Actual: ambil subset dari projection + noise kecil
    func makeActual(from projection: [DataPoint], upToMonths count: Int) -> [DataPoint] {
        let capped = max(1, min(count, projection.count))
        return projection.prefix(capped).enumerated().map { (idx, p) in
            // noise ±3% dari nilai untuk “real-life wobble”
            let noise = p.value * Double.random(in: -0.03...0.03)
            return DataPoint(date: p.date, value: max(1, p.value + noise))
        }
    }
}

struct PortfolioScreen_PreviewWrapper: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let di = AppDI.live(modelContext: modelContext)
        PortfolioScreen(service: di.portfolioService)
    }
}
