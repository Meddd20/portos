//
//  TransactionRow.swift
//  portos
//
//  Created by James Silaban on 24/08/25.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionItem
    
    var iconName: String {
        switch transaction.type {
            case .buy: return "plus"
            case .sell: return "minus"
            case .allocateIn: return "arrow.left"
            case .allocateOut: return "arrow.right"
        }
    }
    
    var body: some View {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: iconName).font(.subheadline))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(transaction.lots) lot".localized).font(.body.weight(.semibold))
                    if let note = transaction.note {
                        Text(note).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let amt = transaction.amount {
//                        Text(cashFormatter(Double(amt))).font(.body.weight(.semibold))
                    } else {
                        Text("")
                    }
                    if let p = transaction.platform {
                        Text(p).font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 12)
        }
}

#Preview {
    TransactionRow(transaction: TransactionItem(
        type: .allocateIn,
        lots: 80,
        note: "-",
        amount: 8_000_000,
        platform: "Bibit",
        date: Date())
    )
}
