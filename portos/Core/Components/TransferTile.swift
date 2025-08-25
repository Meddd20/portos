//
//  TransferTile.swift
//  portos
//
//  Created by Medhiko Biraja on 25/08/25.
//

import Foundation
import SwiftUI

struct TransferTile: View {
    let transferTransaction: TransferTransaction
    let onDelete: () -> Void
//    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "arrow.right")
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
                Text(transferTransaction.fromTransaction.asset.name)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 140, alignment: .leading)
                
                HStack{
                    Text("\(transferTransaction.fromTransaction.portfolio.name)")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.5))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Image(systemName: "arrow.forward")
                    
                    Text("\(transferTransaction.toTransaction.portfolio.name)")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.5))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                
                HStack(spacing: 4) {
                    Text("\(transferTransaction.amount)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    
                    Text(transferTransaction.fromTransaction.asset.assetType.unit)
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                }
                
                Text(transferTransaction.fromTransaction.app.name)
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.5))
                
            }
            .padding(.trailing, 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 3)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                onDelete()
            }, label: {
                Label("Delete", systemImage: "trash")
            })
            
            Button {
//                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
