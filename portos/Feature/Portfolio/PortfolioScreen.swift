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
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(di: AppDI) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(di: di))
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
    @State private var isExpanded = false
    @State private var expandedGroupID: UUID? = nil
    private let collapsedCount = 3
    
    @State private var showMore: Bool = false
    
    @Query(sort: \Portfolio.createdAt) var portfolios: [Portfolio]
    
    var body: some View {
        @State var expandedGroups: Set<UUID> = []
        
        VStack(alignment: .center) {
            PickerSegmented(
                selectedIndex: $selectedIndex,
                titles: ["All"] + portfolios.map { $0.name },
                onChange: onPickerChange,
                onAdd: { showingAdd = true }
            )
            
            // for debug
//            Button("print ACTUAL Series for chart", action: {print("fnkcdsjfn cjdn fkjndjknfck \n \(viewModel.actualSeries)")})
//            Button("print PROJECTION Series for chart", action: {print("PROJECTION: \(viewModel.projectionSeries)")})
//            Button("???", action: {print(viewModel.actualSeries == viewModel.projectionSeries)})
//            Button("refresh api", action: {viewModel.refreshMarketValues()})
//            Button("generate projection", action: {viewModel.calculateProjection()})
            
            ScrollView {
                if selectedIndex == 0 {
                    AssetAllocationAllChart(overview: viewModel.portfolioOverview)
                        .padding(.top, 39)
                } else {
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
                    }
                    if viewModel.actualSeries.isEmpty {
                        EmptyInvestmentChart()
                            .frame(height: 184)
                            .padding(.top, 32)
                    } else {
                        InvestmentChartWithRange(projection: nil, actual: viewModel.actualSeries)
                                            .frame(height: 184)
                                            .padding(.top, 32)
                    }
                }
                
                HStack {
                    CircleButton(systemName: "arrow.trianglehead.clockwise", title: "History") {
                        let portfolio = selectedIndex == 0 ? nil : portfolios[selectedIndex - 1]
                        navigationManager.push(.transactionHistory(portfolio: portfolio), back: BackAction.popOnce )
                    }
                    
                    CircleButton(systemName: "plus", title: "Add") {
                        let portfolio = (selectedIndex == 0) ? nil : portfolios[selectedIndex - 1]
                        navigationManager.push(.searchAsset(currentPortfolio: portfolio), back: BackAction.popOnce)
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
                
                if viewModel.portfolioOverview.groupItems.isEmpty {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 58))
                        .padding(.top, 98)
                        .foregroundColor(Color.primaryApp.opacity(0.75))
                    
                    Text(selectedIndex == 0 ? "No Portfolio" : "No Asset")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 15)
                        .multilineTextAlignment(.center)
                    
                    Text(selectedIndex == 0 ? "Create portfolios, and they will be here." : "Try add an asset, and it will be shown here.")
                        .font(.system(size: 17))
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                } else {
                    assetGroupsList
                }
            }.scrollIndicators(.hidden)
                .padding()
        }
        .task { await viewModel.loadChartData() }
        .navigationBarBackButtonHidden()
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
            viewModel.refreshMarketValues()
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
    }
    
    @ViewBuilder
    private var assetGroupsList: some View {
        ForEach(viewModel.portfolioOverview.groupItems, id: \.id) { group in
            assetGroupSection(group: group)
        }
    }

    @ViewBuilder
    private func assetGroupSection(group: AssetGroup) -> some View {
        let isExpanded = expandedGroupID == group.id
        HStack {
            Text(group.name!)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Text("Rp \(group.value!)")
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(.top, 32)
        
        Divider()
            .frame(height: 0)
            .foregroundStyle(Color(red: 0.73, green: 0.73, blue: 0.73).opacity(0.2))
            .padding(.top, 16)
        
        ForEach(displayedAssets(for: group, isExpanded: isExpanded), id: \.id) { asset in
            assetItemRow(asset: asset)
        }
        
        if group.assets.count > collapsedCount {
            Button {
                withAnimation {
                    toggleGroup(group)
                }
            } label: {
                HStack {
                    Spacer()
                    Text(isExpanded ? "View Less" : "View More")
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.top, 4)
            }
        }
    }
    
    private func displayedAssets(for group: AssetGroup, isExpanded: Bool) -> [AssetItem] {
        if isExpanded { return group.assets }
        return Array(group.assets.prefix(collapsedCount))
    }
    
    private func toggleGroup(_ group: AssetGroup) {
        let id = group.id
        if expandedGroupID == id {
            expandedGroupID = nil
        } else {
            expandedGroupID = id
        }
    }

    @ViewBuilder
    private func assetItemRow(asset: AssetItem) -> some View {
        VStack {
            HStack {
                Text(asset.name!)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Text("Rp \(asset.value!)")
                    .font(.body)
            }
            .padding(.top, 10)
            
            HStack {
                if selectedIndex != 0 {
                    Text(asset.quantity!)
                        .font(.system(size: 15))
                    Text("•")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.textPlaceholderApp)
                    Text(viewModel.getPlatforms(transactions: asset.holding?.transactions ?? []))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.textPlaceholderApp)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                growthRateLabel(for: asset.growthRate!)
            }
            .padding(.top, 8)
            
            Divider()
                .frame(height: 0)
                .foregroundStyle(Color(red: 0.73, green: 0.73, blue: 0.73).opacity(0.2))
                .padding(.top, 10)
        }
        .onTapGesture {
            if let holding = asset.holding {
                navigationManager.push(.detailHolding(holding: holding), back: .popOnce)
            }
        }
    }

    @ViewBuilder
    private func growthRateLabel(for growthRate: Decimal) -> some View {
        if growthRate >= 0 {
            Label("\(growthRate)%", systemImage: "arrowtriangle.up.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color.greenApp)
        } else {
            Label("\(growthRate)%", systemImage: "arrowtriangle.down.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.8, green: 0.14, blue: 0.15))
        }
    }
    
    func onPickerChange() {
        let name = (selectedIndex == 0) ? nil : portfolios[selectedIndex-1].name
        viewModel.getPortfolioOverview(portfolioName: name)
        viewModel.refreshMarketValues()
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
