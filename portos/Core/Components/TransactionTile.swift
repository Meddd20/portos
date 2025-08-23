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

    var transactionIcon: String {
        switch transaction.transactionType {
        case .buy: return "plus"
        case .sell: return "minus"
        default: return "arrow.down.right"
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: transactionIcon)
                .font(.system(size: 20))
                .fontWeight(.thin)
                .foregroundStyle(.black)
                .clipShape(Circle())
                .frame(width: 40, height: 40, alignment: .center)
                .background(
                    Circle().foregroundStyle(Color.gray.opacity(0.1))
                )
                .overlay(
                    Circle().stroke(.black.opacity(0.2), lineWidth: 0.2)
                )
            
            Spacer()
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(transaction.quantity) \(transaction.asset.assetType.unit)")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                if transaction.transactionType == .buy || transaction.transactionType == .sell{
                    Text("Rp \(transaction.price)")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.5))
                } else {
                    if let transferTransaction = transaction.transferTransaction {
                        let portfolioFrom = transferTransaction.fromTransaction.portfolio.name
                        let portfolioTo = transferTransaction.toTransaction.portfolio.name
                        
                        HStack{
                            Text("\(portfolioFrom)")
                                .font(.system(size: 13))
                                .foregroundStyle(.black.opacity(0.5))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Image(systemName: "arrow.forward")
                            
                            Text("\(portfolioTo)")
                                .font(.system(size: 13))
                                .foregroundStyle(.black.opacity(0.5))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Text("Rp")
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                    
                    Text("\(transaction.quantity * transaction.price)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                }
                
                Text(transaction.app.name)
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.5))
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
    }
}
