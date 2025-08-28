//
//  TransferTile.swift
//  portos
//
//  Created by Medhiko Biraja on 25/08/25.
//

import Foundation
import SwiftUI

struct TransferTile: View {
    let outTransaction: Transaction
    let inTransaction: Transaction
    let isInOutHistory: Bool
    let isAllOrHolding: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: isInOutHistory ? "arrow.right" : "arrow.left")
                .font(.system(size: 20))
                .fontWeight(.thin)
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
                Text(outTransaction.asset.name)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 140, alignment: .leading)
                
                if isInOutHistory {
                    if isAllOrHolding {
                        HStack {
                            Text("\(outTransaction.portfolio.name)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Image(systemName: "arrow.right")
                            
                            Text("\(inTransaction.portfolio.name)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    } else {
                        Text("To \(inTransaction.portfolio.name)")
                            .font(.system(size: 13))
                            .foregroundStyle(.black.opacity(0.5))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                } else {
                    if isAllOrHolding {
                        HStack {
                            Text("\(outTransaction.portfolio.name)")
                                .font(.system(size: 13))
                                .foregroundStyle(.black.opacity(0.5))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Image(systemName: "arrow.right")
                            
                            Text("\(inTransaction.portfolio.name)")
                                .font(.system(size: 13))
                                .foregroundStyle(.black.opacity(0.5))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    } else {
                        Text("From \(outTransaction.portfolio.name)")
                            .font(.system(size: 13))
                            .foregroundStyle(.black.opacity(0.5))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                
                HStack(spacing: 4) {
                    Text("\(outTransaction.quantity)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    
                    Text(outTransaction.asset.assetType.unit)
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                }
                
                Text(outTransaction.app.name)
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
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
