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
    @StateObject private var viewModel: TransactionHistoryViewModel
    @State private var selectedTransactionForEdit: Transaction?
    
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
                                if let tt = transaction.transferTransaction {
                                    if tt.fromTransaction.persistentModelID == transaction.id {
                                        TransferTile(transferTransaction: tt)
                                            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                                            .listRowSeparator(.hidden)
                                    } else {
                                        EmptyView() // skip the "to" leg
                                    }
                                } else {
                                    TransactionTile(
                                        transaction: transaction,
                                        onDelete: { viewModel.deleteTransaction(transactionId: transaction.id) },
                                        onEdit: { selectedTransactionForEdit = transaction }
                                    )
                                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                                    .listRowSeparator(.hidden)
                                }
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
