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
    @StateObject private var viewModel: TransferTransactionViewModel
    
    init(di: AppDI, asset: Asset, transferMode: TransferMode) {
        _viewModel = StateObject(
            wrappedValue: TransferTransactionViewModel(
                di: di,
                asset: asset,
                transferMode: transferMode
            )
        )
    }
    
    var body: some View {
        Spacer()
            .frame(height: 40)
        
        Text("BBCA")
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.title)
            .fontWeight(.bold)
        
        Spacer()
            .frame(height: 9)
            
        Text("PT Bank Central Asia Tbk.")
            .frame(maxWidth: .infinity, alignment: .center)
        
        Spacer()
            .frame(height: 44)
        
        Divider()
            .padding(.vertical, 10)
            .ignoresSafeArea(edges: .all)
            .frame(maxWidth: .infinity)
        
        VStack {
            FormRow(label: "Amount") {
                TextField("0 Lot", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
            }
            
            Divider()
                .padding(.vertical, 10)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity)
            
            FormRow(label: "From") {
                Menu {
                    ForEach(viewModel.portfolios, id: \.id) { portfolio in
                        Button(portfolio.name) {
                            viewModel.portfolioTransferFrom = portfolio
                        }
                    }
                } label: {
                    if viewModel.portfolioTransferFrom?.name == nil {
                        HStack {
                            Text("Select Portfolio")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tint(.black)
                        }
                    } else {
                        Text(viewModel.portfolioTransferFrom?.name ?? "")
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
            
            
//            Button(action: {
//                Task {
//                    Task { await viewModel.proceedTransaction() }
//                }
//            }, label: {
//                Text("Confirm")
//                    .buttonStyle(.borderedProminent)
//                    .frame(width: 306, height: 53)
//                    .background(viewModel.isDataFilled ? .blue : Color(red: 0.7, green: 0.7, blue: 0.7))
//                    .tint(.white)
//                    .cornerRadius(24)
//            })
//            .disabled(viewModel.isDataFilled ? false : true)
        }
    }
}
