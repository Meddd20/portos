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
    private var di: AppDI { AppDI.live(modelContext: modelContext) }
    
    @StateObject private var viewModel: PortfolioViewModel
    
    init(service: PortfolioService) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(service: service))
    }

    @State private var selection: Portfolio?
    @State private var selectionID: UUID? = nil
    @State private var selectedIndex: Int = 0
    @State private var showingAdd = false
    
    @Query(sort: \Portfolio.createdAt) var portfolios: [Portfolio]
    
    var body: some View {
        VStack(alignment: .center) {
            PickerSegmented(
                selectedIndex: $selectedIndex,
                titles: ["All"] + portfolios.map { $0.name },
                onChange: onPickerChange
            )
            
            ScrollView {
                VStack(alignment: .center) {
                    Text("Rp \(viewModel.portfolioValue)")
                        .padding(.top, 27)
                    
                    HStack(alignment: .center) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 12))

                        Text("\(viewModel.growthRate)%")
                            .font(.system(size: 16, weight: .regular))
                            .padding(.trailing, 14)

                        Text("Rp \(viewModel.profitAmount)")
                            .font(.system(size: 16, weight: .regular))
                    }
                    .foregroundColor(Color(red: 0.05, green: 0.6, blue: 0.11))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(red: 0.86, green: 0.92, blue: 0.86))
                    .cornerRadius(14)
                }
                Spacer().frame(width: 391, height: 184).padding(.top, 23.04)
                HStack {
                    CircleButton(systemName: "arrow.trianglehead.clockwise", title: "History", action: { print("history clicked") })
                    CircleButton(systemName: "plus", title: "Add", action: { showingAdd = true })
                    CircleButton(systemName: "ellipsis", title: "More", action: { print("more clicked") })
                }
                ForEach(viewModel.assetPositions, id: \.id) { assetPosition in
                    HStack {
                        Text(assetPosition.assetType.displayName)
                            .font(.system(size: 28))
                        Spacer()
                        VStack {
                            Text("Rp \(viewModel.getValue(holdings: assetPosition.holdings))")
                        }
                    }.padding(.top, 39)
                    Divider().frame(height: 1)
                    
                    ForEach(assetPosition.holdings, id: \.id) { holding in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(holding.asset.name)
                                    .font(.system(size: 20))
                                Text("\(viewModel.getHoldingQuantity(holding: holding, assetType: assetPosition.assetType))")
                                    .font(.system(size: 13))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Rp \(viewModel.getHoldingValue(holding: holding))")
                                    .font(.system(size: 17))
                                Text("\(viewModel.getGrowthRateOnHolding(holding: holding))%")
                                    .font(.system(size: 12))
                            }
                        }.padding(.top, 10)
                    }
                }
            }.scrollIndicators(.hidden)  
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .sheet(isPresented: $showingAdd) {
            AddPortfolioSheet(service: di.portfolioService)
        }
        .onAppear() {
            viewModel.load()
            viewModel.getHoldings(portfolioName: "All")
            viewModel.getPortfolioValue(portfolioName: "All")
            viewModel.getProfitAmount(portfolioName: "All")
            viewModel.getGrowthRate(portfolioName: "All")
        }
    }

    private func onPickerChange() {
        let name = (selectedIndex == 0) ? "All" : portfolios[selectedIndex-1].name
        viewModel.getHoldings(portfolioName: name)
        viewModel.getPortfolioValue(portfolioName: name)
        viewModel.getProfitAmount(portfolioName: name)
        viewModel.getGrowthRate(portfolioName: name)
    }
}



