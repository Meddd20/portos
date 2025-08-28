//
//  TransferTransactionView.swift
//  portos
//
//  Created by Medhiko Biraja on 22/08/25.
//

import Foundation
import SwiftUI

struct TransferTransactionView: View {
    @Environment(\.di) private var di
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel: TransferTransactionViewModel
    let asset: Asset
    let holding: Holding
    let transaction: Transaction?
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode, holding: Holding, transaction: Transaction? = nil) {
        self.asset = asset
        self.holding = holding
        self.transaction = transaction
        _viewModel = StateObject(
            wrappedValue: TransferTransactionViewModel(
                di: di,
                asset: asset,
                transferMode: transferMode,
                holding: holding,
                transaction: transaction
            )
        )
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 40)
            
            Text(asset.symbol)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
                .frame(height: 9)
            
            Text(asset.name)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(Color.textSecondary)
            
            Spacer()
                .frame(height: 44)
            
            FormRow(label: "Amount") {
                TextField("0 \(viewModel.asset.assetType.unit)", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color.textPrimary)
            }
            
            Divider()
                .padding(.vertical, 10)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity)
            
            FormRow(label: "From") {
                Text(viewModel.portfolioTransferFrom?.name ?? "")
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.textPrimary)
            }
            
            Divider()
                .padding(.vertical, 10)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity)
            
            FormRow(label: "To") {
                Menu {
                    ForEach(viewModel.portfolios, id: \.id) { portfolio in
                        Button(portfolio.name) {
                            viewModel.portfolioTransferTo = portfolio
                        }
                    }
                } label: {
                    if viewModel.portfolioTransferTo?.name == nil {
                        HStack {
                            Text("Select Portfolio")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.textSecondary)
                        }
                    } else {
                        Text(viewModel.portfolioTransferTo?.name ?? "")
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.textPrimary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
                .tint(Color.textPrimary)
            }
            
            Divider()
                .padding(.vertical, 10)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity)
            
            FormRow(label: "Platform") {
                Menu {
                    ForEach(viewModel.platforms, id: \.id) { platform in
                        Button(platform.name) {
                            viewModel.platform = platform
                        }
                    }
                } label: {
                    if viewModel.platform?.name == nil {
                        HStack {
                            Text("Select Platform")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.textSecondary)
                        }
                    } else {
                        Text(viewModel.platform?.name ?? "")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
                .tint(Color.textPrimary)
            }
            
            Spacer()
            
            if viewModel.transferMode == .transferToPortfolio || (viewModel.transferMode == .editTransferTransaction && viewModel.isDataFilled) {
                Button(action: {
                    viewModel.proceedTransaction()
                    navigationManager.back()
                }, label: {
                    Text("Confirm")
                        .frame(width: 306, height: 53)
                        .background(viewModel.isDataFilled ? Color.ctaEnabledBackground : Color.ctaDisabledBackground)
                        .foregroundStyle(Color.ctaEnabledText)
                        .cornerRadius(24)
                })
                .disabled(viewModel.isDataFilled ? false : true)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(Text("Transferring \(viewModel.asset.assetType.displayName)"))
        .navigationBarTitleDisplayMode(.inline)
        .padding(EdgeInsets(top: 0, leading: 42, bottom: 0, trailing: 36))
        .onAppear {
            viewModel.loadData()
        }
        .toolbar {
            ToolbarItem (placement: .topBarLeading) {
                Button (action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.textPrimary)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        .toolbarBackground(Color.backgroundApp, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(
            LinearGradient(
            stops: [
                Gradient.Stop(color: Color.backgroundPrimary, location: 0.13),
                Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1) ))
    }
}
