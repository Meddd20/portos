//
//  DetailHoldingView.swift
//  portos
//
//  Created by James Silaban on 23/08/25.
//

import SwiftUI

struct InvestmentItem: Identifiable {
    var id: String { platform }  // Make `platform` the unique identifier
    
    var platform: String
    var totalValue: Double
    var quantityLabel: String
    var currentPrice: Double
    var averagePrice: Double
}

struct TransactionItem: Identifiable {
    let id = UUID()
    let type: TransactionType
    let lots: Int
    let note: String?             // e.g. "Retirement → Education"
    let amount: Int?              // nil for transfers with no amount shown on right
    let platform: String?         // e.g. "Bibit", "Pintu"
    let date: Date
}

struct DetailHoldingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.di) private var di
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @State private var rowHeight: CGFloat = 0
    @State private var selectedTransactionForEdit: Transaction?
    @State private var selectedTransferForEdit: Transaction?
    
    @StateObject private var viewModel: DetailHoldingViewModel
    let holding: Holding
    let today = Calendar.current.startOfDay(for: Date())
    
    init(di: AppDI, holding: Holding) {
        self.holding = holding
        _viewModel = StateObject(wrappedValue: DetailHoldingViewModel(di: di, holding: holding))
    }
        
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                VStack{
                    Text(viewModel.holding.asset.name)
                        .font(.title3)
                        .fontWeight(.none)
                        .padding(.vertical, 1)
                        .foregroundStyle(Color.textPrimary)

                    Text("\(viewModel.holding.asset.currency.symbol) \((viewModel.holdingAssetDetail?.portfolioMarketValue.formattedCash()) ?? "-")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.vertical, 1)
                        .foregroundStyle(Color.textPrimary)
                    
                    InformationPill(
                        trailingText: viewModel.holdingAssetDetail?.unrealizedPnLPercentage.formattedPercentage(),
                        backgroundColor: getPillBackgroundColor(),
                        fontColor: getPillFontColor(),
                        showBackground: true,
                        iconName: getPillIconName()
                    )
                }
                .padding(.horizontal, 16)
                
                
                if viewModel.accountPosition.count == 1 {
                    ForEach(viewModel.accountPosition, id: \.appSource.id) { account in
                        HoldingSummaryCard(
                            platform: account.appSource.name,
                            totalValue: account.unrealizedPnL + (account.avgCost * account.qty),
                            quantityLabel: account.qty.description,
                            currentPrice: account.lastPrice,
                            averagePrice: account.avgCost,
                            unit: viewModel.holding.asset.assetType.unit,
                            asset: viewModel.holding.asset,
                            showAmounts: .constant(true)
                        )
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(viewModel.accountPosition, id: \.appSource.id) { account in
                                HoldingSummaryCard(
                                    platform: account.appSource.name,
                                    totalValue: account.unrealizedPnL + (account.avgCost * account.qty),
                                    quantityLabel: account.qty.description,
                                    currentPrice: holding.asset.lastPrice,
                                    averagePrice: account.avgCost,
                                    unit: viewModel.holding.asset.assetType.unit,
                                    asset: viewModel.holding.asset,
                                    showAmounts: .constant(true)
                                )
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                    }
                }
                
                HStack(alignment: .center, spacing: 42) {
                    CircleButton(
                        systemName: "plus",
                        title: "add".localized,
                        action: {
                            navigationManager.push(.buyAsset(asset: holding.asset, portfolio: holding.portfolio), back: .popOnce)
                        }
                    )
                    .foregroundStyle(Color.greenApp) // Green for Add
                    
                    CircleButton(
                        systemName: "minus",
                        title: "liquidating".localized,
                        action: {
                            navigationManager.push(.sellAsset(asset: holding.asset, portfolio: holding.portfolio, holding: holding), back: .popOnce)
                        }
                    )
                    .foregroundStyle(Color.redApp) // Red for Liquidate
                    
                    CircleButton(
                        systemName: "arrow.right",
                        title: "transfer".localized,
                        action: {
                            navigationManager.push(.transferAsset(asset: holding.asset, holding: holding, transferMode: .transferToPortfolio), back: .popOnce)
                        }
                    )
                    .foregroundStyle(Color.primaryApp) // Brown for Transfer
                }
                .padding(.horizontal, 16)
                                
                if !viewModel.transactionSectionedByDate.isEmpty {
                    List {
                        ForEach(viewModel.transactionSectionedByDate, id: \.id) { section in
                            Section(header: sectionHeader(for: section)) {
                                ForEach(section.transactions, id: \.id) { transaction in
                                    TransactionRowView(
                                        transaction: transaction,
                                        portfolio: transaction.portfolio,
                                        section: section,
                                        allTransactions: viewModel.allTransactions,
                                        isAllOrHolding: false,
                                        onDeleteTransaction: { viewModel.deleteTransaction(transactionId: transaction.id) },
                                        onEditTransaction: { selectedTransactionForEdit = transaction },
                                        onEditTransfer: { selectedTransferForEdit = transaction }
                                    )
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            }
                            .listSectionSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .scrollDisabled(true)
                    .frame(height: calculateListHeight())
                }
            }
        }
        .background(
            LinearGradient(
            stops: [
                Gradient.Stop(color: Color.backgroundPrimary, location: 0.13),
                Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1) ))
        .navigationTitle(viewModel.holding.asset.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem (placement: .topBarLeading) {
                Button (action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .toolbarBackground(Color.backgroundApp, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            viewModel.getHoldingAssetDetail()
            viewModel.getTransactions()
        }
        .onChange(of: selectedTransactionForEdit) { tx in
            if let transaction = tx {
                navigationManager.push(
                    .editTransaction(
                        transaction: transaction,
                        transactionMode: .editBuy,
                        asset: transaction.asset,
                        portfolio: transaction.portfolio
                    ),
                    back: .popOnce
                )
                selectedTransactionForEdit = nil
            }
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 8)
        }
    }
    
    @ViewBuilder
    private func sectionHeader(for section: TransactionSection) -> some View {
        let sectionTitle: String = section.date == today
        ? "Today"
        : section.date.formatted(date: .abbreviated, time: .omitted)
        
        VStack{
            HStack {
                Text(sectionTitle)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
            }
            .padding(.bottom, 8)
            .background(Color.clear)
        }
    }
    
    private func calculateListHeight() -> CGFloat {
        let sectionsCount = viewModel.transactionSectionedByDate.count
        let totalTransactions = viewModel.transactionSectionedByDate.reduce(0) { $0 + $1.transactions.count }
        
        let headerHeight: CGFloat = 40 // Approximate header height
        let rowHeight: CGFloat = 70 // Approximate row height
        let sectionSpacing: CGFloat = 20
        
        return CGFloat(sectionsCount) * headerHeight +
               CGFloat(totalTransactions) * rowHeight +
               CGFloat(sectionsCount) * sectionSpacing
    }
    
    private func getPillBackgroundColor() -> Color {
        let percentage = viewModel.holdingAssetDetail?.unrealizedPnLPercentage ?? 0
        if percentage < 0 {
            return Color.redApp.opacity(0.15)
        } else if percentage > 0 {
            return Color.greenApp.opacity(0.15)
        } else {
            return Color.greyApp.opacity(0.15)
        }
    }
    
    private func getPillFontColor() -> Color {
        let percentage = viewModel.holdingAssetDetail?.unrealizedPnLPercentage ?? 0
        if percentage < 0 {
            return Color.redApp
        } else if percentage > 0 {
            return Color.greenApp
        } else {
            return Color.greyApp
        }
    }
    
    private func getPillIconName() -> String {
        let percentage = viewModel.holdingAssetDetail?.unrealizedPnLPercentage ?? 0
        if percentage < 0 {
            return "arrowtriangle.down.fill" // Down arrow for negative
        } else if percentage > 0 {
            return "arrowtriangle.up.fill" // Up arrow for positive
        } else {
            return "arrowtriangle.up" // No change for zero
        }
    }
}
