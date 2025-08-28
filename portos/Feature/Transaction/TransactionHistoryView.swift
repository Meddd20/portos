//
//  TransactionHistoryView.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation
import SwiftUI

struct TransactionHistoryView: View {
    @Environment(\.di) private var di
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel: TransactionHistoryViewModel
    @State private var selectedTransactionForEdit: Transaction?
    @State private var selectedTransferForEdit: Transaction?
    
    let portfolio: Portfolio?
    let today = Calendar.current.startOfDay(for: Date())
    
    init(di: AppDI, portfolio: Portfolio? = nil) {
        self.portfolio = portfolio
        _viewModel = StateObject(
            wrappedValue: TransactionHistoryViewModel(
                di: di,
                portfolio: portfolio
            )
        )
    }
    
    var body: some View {
        Group {
            if !viewModel.transactionSectionedByDate.isEmpty {
                List {
                    ForEach(viewModel.transactionSectionedByDate, id: \.id) { section in
                        Section {
                            ForEach(section.transactions, id: \.id) { transaction in
                                TransactionRowView(
                                    transaction: transaction,
                                    portfolio: portfolio,
                                    section: section,
                                    allTransactions: viewModel.transactions,
                                    isAllOrHolding: portfolio == nil,
                                    onDeleteTransaction: { viewModel.deleteTransaction(transactionId: transaction.id) },
                                    onEditTransaction: { selectedTransactionForEdit = transaction },
                                    onEditTransfer: { selectedTransferForEdit = transaction }
                                )
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            sectionHeader(for: section)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
            } else {
                VStack {
                    Image(systemName: "questionmark.circle.dashed")
                        .font(.system(size: 60))
                        .fontWeight(.regular)
                        .opacity(0.75)
                        .frame(width: 60, height: 60)
                    
                    Spacer()
                        .frame(height: 15)

                    Text("No History")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    Text("When you add, liquidate, or transfer your assets, their records are here.")
                        .frame(maxWidth: 300, alignment: .center)
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
        }
        
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
            viewModel.getTransactions()
        }
        .navigationBarTitle("\(viewModel.historyOf) History")
        .navigationBarBackButtonHidden()
        .onChange(of: selectedTransferForEdit) { newValue in
            guard let tx = newValue else { return }
            
            let route: NavigationRoute = .editTransfer(transaction: tx, asset: tx.asset, holding: tx.holding, transferMode: .editTransferTransaction)
            
            navigationManager.push(route, back: BackAction.popOnce)
            selectedTransferForEdit = nil
            
        }
        .onChange(of: selectedTransactionForEdit) { newValue in
            guard let tx = newValue else { return }
            
            let route: NavigationRoute = .editTransaction(
                transaction: tx,
                transactionMode: .editBuy,
                asset: tx.asset,
                portfolio: tx.portfolio
            )

            navigationManager.push(route, back: BackAction.popOnce)
            selectedTransactionForEdit = nil
        }
    }
    
    @ViewBuilder
    private func sectionHeader(for section: TransactionSection) -> some View {
        let sectionTitle: String = section.date == today
        ? "Today"
        : section.date.formatted(date: .abbreviated, time: .omitted)
        
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

struct TransactionRowView: View {
    let transaction: Transaction
    let portfolio: Portfolio?
    let section: TransactionSection
    let allTransactions: [Transaction]
    let isAllOrHolding: Bool
    let onDeleteTransaction: () -> Void
    let onEditTransaction: () -> Void
    let onEditTransfer: () -> Void
    
    private var shouldShow: Bool {
        if portfolio == nil {
            if transaction.transferGroupId != nil {
                return transaction.transactionType == .allocateOut
            } else {
                return true
            }
        } else {
            return transaction.portfolio.id == portfolio?.id
        }
    }
    
    @ViewBuilder
    var body: some View {
        if shouldShow {
            if transaction.transferGroupId != nil {
                TransferRowView(
                    transaction: transaction,
                    portfolio: portfolio,
                    sectionTransactions: section.transactions,
                    allTransactions: allTransactions,
                    isAllOrHolding: isAllOrHolding,
                    onDelete: onDeleteTransaction,
                    onEdit: onEditTransfer
                )
            } else {
                TransactionTile(
                    transaction: transaction,
                    onDelete: onDeleteTransaction,
                    onEdit: onEditTransaction
                )
            }
        } else {
            EmptyView()
        }
    }
}

struct TransferRowView: View {
    let transaction: Transaction
    let portfolio: Portfolio?
    let sectionTransactions: [Transaction]
    let allTransactions: [Transaction]
    let isAllOrHolding: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void
        
    private var isOut: Bool {
        transaction.transactionType == .allocateOut
    }
    
    private var oppositeType: TransactionType {
        isOut ? .allocateIn : .allocateOut
    }
    
    private var pairTransaction: Transaction? {
        allTransactions.first{
            $0.transferGroupId == transaction.transferGroupId &&
            $0.transactionType == oppositeType &&
            $0.id != transaction.id
        }
    }
        
    var body: some View {
        let outTx = isOut ? transaction : pairTransaction
        let inTx = isOut ? pairTransaction : transaction
                
        if let inTx, let outTx {
            TransferTile(
                outTransaction: outTx,
                inTransaction: inTx,
                isInOutHistory: isOut,
                isAllOrHolding: isAllOrHolding,
                onDelete: onDelete,
                onEdit: onEdit
            )
        }
    }
}
