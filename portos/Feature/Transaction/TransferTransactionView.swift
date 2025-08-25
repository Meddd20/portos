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
    @StateObject private var viewModel: TransferTransactionViewModel
    let asset: Asset
    let holding: Holding
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode, holding: Holding) {
        self.asset = asset
        self.holding = holding
        _viewModel = StateObject(
            wrappedValue: TransferTransactionViewModel(
                di: di,
                asset: asset,
                transferMode: transferMode,
                holding: holding
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
            
            Spacer()
                .frame(height: 9)
            
            Text(asset.name)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
                .frame(height: 44)
            
            FormRow(label: "Amount") {
                TextField("0 \(viewModel.asset.assetType.unit)", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
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
                    .tint(.black)
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
                                .tint(.black)
                        }
                    } else {
                        Text(viewModel.portfolioTransferTo?.name ?? "")
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tint(.black)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .font(.system(size: 12))
                        .tint(.black)
                }
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
                                .tint(.black)
                        }
                    } else {
                        Text(viewModel.platform?.name ?? "")
                            .font(.system(size: 16))
                            .tint(.black)
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
                        .tint(.black)
                }
            }
            
            Spacer()
            
            if viewModel.transferMode == .transferToPortfolio || (viewModel.transferMode == .editTransferTransaction && viewModel.isDataFilled) {
                Button(action: {
                    viewModel.proceedTransaction()
                }, label: {
                    Text("Confirm")
                        .buttonStyle(.borderedProminent)
                        .frame(width: 306, height: 53)
                        .background(viewModel.isDataFilled ? .blue : Color(red: 0.7, green: 0.7, blue: 0.7))
                        .tint(.white)
                        .cornerRadius(24)
                })
                .disabled(viewModel.isDataFilled ? false : true)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(Text("Transferring \(viewModel.asset.assetType.displayName)"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.didFinishTransaction) {
            PortfolioScreen(service: viewModel.portfolioService)
        }
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
                        .foregroundColor(.black)
                }
            }
        }
    }
}
