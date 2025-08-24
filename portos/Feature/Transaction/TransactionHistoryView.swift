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
        VStack {
            ForEach(viewModel.transactionSectionedByDate, id: \.id) { section in
                Text(section.date == today ? "Today" : section.date.formatted(date: .abbreviated, time: .omitted))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                Divider()
                    .padding(.vertical, 8)
                    .ignoresSafeArea(edges: .all)
                    .frame(maxWidth: .infinity)
                
                ForEach(section.transactions, id: \.id) { transaction in
                    HStack(alignment: .top) {
                        TransactionTile(transaction: transaction)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                }
                
                Spacer()
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 26)
        .padding(.top, 15)
        .onAppear {
            viewModel.getTransactions()
        }
        .navigationBarTitle("\(viewModel.historyOf) History")
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
    }
}
