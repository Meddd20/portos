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
                    
                    Text((viewModel.holdingAssetDetail?.unrealizedPnLValue.formattedCash()) ?? "-")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.vertical, 1)
                    
                    InformationPill(
                        trailingText: viewModel.holdingAssetDetail?.unrealizedPnLPercentage.formattedPercentage(),
                        backgroundColor: Color.green.opacity(0.15),
                        fontColor: Color(hue: 0.33, saturation: 0.75, brightness: 0.55),
                        showBackground: true
                    )
                }
                .padding(.horizontal, 16)
                
                
                if viewModel.accountPosition.count == 1 {
                    ForEach(viewModel.accountPosition, id: \.appSource.id) { account in
                        HoldingSummaryCard(
                            platform: account.appSource.name,
                            totalValue: account.unrealizedPnL,
                            quantityLabel: account.qty.description,
                            currentPrice: account.avgCost,
                            averagePrice: account.avgCost,
                            unit: viewModel.holding.asset.assetType.unit,
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
                                    totalValue: account.unrealizedPnL,
                                    quantityLabel: account.qty.description,
                                    currentPrice: holding.asset.lastPrice,
                                    averagePrice: account.avgCost,
                                    unit: viewModel.holding.asset.assetType.unit,
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
                        title: "Add",
                        action: {
                            navigationManager.push(.buyAsset(asset: holding.asset, portfolio: holding.portfolio), back: .popOnce)
                        }
                    )
                    CircleButton(
                        systemName: "minus",
                        title: "Liquidate",
                        action: {
                            navigationManager.push(.sellAsset(asset: holding.asset, portfolio: holding.portfolio), back: .popOnce)
                        }
                    )
                    CircleButton(
                        systemName: "arrow.right",
                        title: "Add",
                        action: {
                            navigationManager.push(.transferAsset(asset: holding.asset, holding: holding, transferMode: .transferToPortfolio), back: .popOnce)
                        }
                    )
                }
                .padding(.horizontal, 16)
                                
                if !viewModel.transactionSectionedByDate.isEmpty {
                    List {
                        ForEach(viewModel.transactionSectionedByDate, id: \.id) { section in
                            Section(header: sectionHeader(for: section)) {
                                ForEach(section.transactions, id: \.id) { tx in
                                    SimpleTransactionRow(
                                        transaction: tx,
                                        section: section,
                                        isAllOrHolding: true,
                                        onDelete: { viewModel.deleteTransaction(transactionId: tx.id) },
                                        onEdit: { selectedTransactionForEdit = tx },
                                        onTransfer: { selectedTransferForEdit = tx }
                                    )
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: calculateListHeight())
                }
            }
            .navigationTitle(viewModel.holding.asset.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem (placement: .topBarLeading) {
                    Button (action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                viewModel.getHoldingAssetDetail()
                viewModel.getTransactions()
            }
            .navigationDestination(item: $selectedTransactionForEdit) { transaction in
                TradeTransactionView(
                    di: di,
                    transactionMode: .editBuy,
                    transaction: transaction,
                    asset: transaction.asset,
                    currentPortfolioAt: transaction.portfolio
                )
            }
        }
        .background(
            LinearGradient(
            stops: [
                Gradient.Stop(color: .white, location: 0.13),
                Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1) ))
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
                    .foregroundStyle(.black)
                
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
}

struct SimpleTransactionRow: View {
    let transaction: Transaction
    let section: TransactionSection
    let isAllOrHolding: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTransfer: () -> Void
    
    var body: some View {
        TransactionRowView(
            transaction: transaction,
            portfolio: transaction.portfolio,
            section: section,
            isAllOrHolding: isAllOrHolding,
            onDeleteTransaction: onDelete,
            onEditTransaction: onEdit,
            onEditTransfer: onEdit
        )
    }
}
