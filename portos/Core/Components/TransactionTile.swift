//
//  TransactionTile.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation
import SwiftUI

struct TransactionTile: View {
    let transaction: Transaction
    let onDelete: () -> Void
    let onEdit: () -> Void

    var transactionIcon: String {
        switch transaction.transactionType {
        case .buy: return "plus"
        case .sell: return "minus"
        default: return "plus"
        }
    }
    
    var transactionAmount: Decimal {
        transaction.quantity * transaction.price
    }
        
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: transactionIcon)
                .font(.system(size: 20))
                .fontWeight(.thin)
                .foregroundStyle(Color.textPrimary)
                .clipShape(Circle())
                .frame(width: 40, height: 40, alignment: .center)
                .background(
                    Circle().foregroundStyle(Color.greyApp.opacity(0.1))
                )
                .overlay(
                    Circle().stroke(Color.borderColor.opacity(0.2), lineWidth: 0.2)
                )
            
            Spacer()
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 8) {
                Text(transaction.asset.name)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 140, alignment: .leading)
                    .foregroundStyle(Color.textPrimary)
                
                Text("\(transaction.app.name) • \(transaction.asset.currency.symbol) \(transaction.price.formattedCash())")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Text("\(transaction.quantity)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    
                    Text(transaction.asset.assetType.unit)
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                }
                
                Text("\(transaction.asset.currency.symbol) \((transactionAmount * Decimal(transaction.asset.assetType.multiplier)).formattedCash())")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
                
            }
            .padding(.trailing, 3)
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 3)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                onDelete()
            }, label: {
                Label("delete".localized, systemImage: "trash")
            })
            
            Button {
                onEdit()
            } label: {
                Label("edit".localized, systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
