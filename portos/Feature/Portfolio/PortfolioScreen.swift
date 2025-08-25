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
    @Environment(\.dismiss) private var dismiss
    
    enum Route: Hashable {
        case settings
        case editPortfolio
        case deletePortfolio
    }
    
    @StateObject private var viewModel: PortfolioViewModel
    @State private var path = NavigationPath()
    
    init(service: PortfolioService) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(service: service))
    }

    @State private var selection: Portfolio?
    @State private var selectionID: UUID? = nil
    @State private var selectedIndex: Int = 0
    @State private var showingAdd = false
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation: Bool = false
    @State private var items: [Holding] = []
    @State private var showTrade = false
    @State private var showTransactionHistory = false
    @State private var selectedHolding: Holding? = nil
    
    @State private var showMore: Bool = false
    
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
                        .font(.system(size: 28, weight: .bold))
                        .kerning(0.38)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top, 32)
                    HStack(alignment: .center) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 15))
                        
                        Text("\(viewModel.portfolioOverview.portfolioGrowthRate!)%")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.trailing, 14)
                        
                        Text("Rp \(viewModel.portfolioOverview.portfolioProfitAmount!)")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(Color.greenApp)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.greenAppLight)
                    .cornerRadius(14)
                    .padding(.bottom, 32)
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
                    
                    Menu {
                        Button("Settings") { print("settings is clicked") }
                        if selectedIndex != 0 {
                            Button("Edit Portfolio")  { showingEdit = true }
                            Button("Delete Portfolio") { showingDeleteConfirmation = true }
                        }
                    } label: {
                        CircleButton(systemName: "ellipsis", title: "More") { }
                            .foregroundStyle(.black)
                    }
                }
                .padding(.top, 32)
                
                ForEach(viewModel.portfolioOverview.groupItems, id: \.id) { item in
                    HStack {
                        Text(item.name!)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Text("Rp \(item.value!)")
                            .font(.system(size: 20, weight: .semibold))
                    }.padding(.top, 32)
                    
                    Divider()
                        .frame(height: 0)
                        .foregroundStyle(Color(red: 0.73, green: 0.73, blue: 0.73).opacity(0.2))
                        .padding(.top, 16)
                    
                    ForEach(item.assets, id: \.id) { asset in
                        VStack {
                            HStack {
                                Text(asset.name!)
                                    .font(.system(size: 17))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                                Text("Rp \(asset.value!)")
                                    .font(.system(size: 17))
                            }
                            .padding(.top, 10)
                            HStack {
                                if (selectedIndex != 0) {
                                    Text(asset.quantity!)
                                        .font(.system(size: 15)) }
                                Spacer()
                                if asset.growthRate! >= 0 {
                                    Label("\(asset.growthRate!)%", systemImage: "arrowtriangle.up.fill")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.greenApp)
                                } else {
                                    Label("\(asset.growthRate!)%", systemImage: "arrowtriangle.down.fill")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color(red: 0.8, green: 0.14, blue: 0.15))
                                }
                            }
                                .padding(.top, 16)
                                .onTapGesture { selectedHolding =  asset.holding }
                            
                            Divider()
                                .frame(height: 0)
                                .foregroundStyle(Color(red: 0.73, green: 0.73, blue: 0.73).opacity(0.2))
                                .padding(.top, 10)
                        }
                    }
                    
                    HStack() {
                        Spacer()
                        Text("View More")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "chevron.down")
                    }.padding(.top, 16)
                }
            }.scrollIndicators(.hidden)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(
            LinearGradient(
            stops: [
                Gradient.Stop(color: .white, location: 0.31),
                Gradient.Stop(color: Color.backgroundApp, location: 0.49),
                ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1) ))
        .navigationDestination(isPresented: $showingAdd) {
            AddPortfolio(di: di, screenMode: .add)
        }
        .navigationDestination(isPresented: $showingEdit) {
            if selectedIndex != 0 {
                AddPortfolio(
                    di: di,
                    screenMode: .edit,
                    portfolio: portfolios[selectedIndex - 1],
                    portfolioName: portfolios[selectedIndex - 1].name,
                    portfolioTargetAmount: formatDecimal(portfolios[selectedIndex - 1].targetAmount) ?? "999999999"
                )
            }
        }
        .onAppear() {
            let name = (selectedIndex == 0) ? nil : portfolios[selectedIndex-1].name
            viewModel.getPortfolioOverview(portfolioName: name)
        }
        .alert("Delete Permanently", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deletePortfolio(id: portfolios[selectedIndex - 1].id)
                selectedIndex -= 1
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone, are you sure to delete this portfolio?")
                .font(.system(size: 13))
        }
        .navigationDestination(item: $selectedHolding) {holding in
            DetailHoldingView(holding: holding)
        }
    }
        func onPickerChange() {
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
