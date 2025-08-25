//
//  TradeTransactionView.swift
//  portos
//
//  Created by Medhiko Biraja on 21/08/25.
//

import Foundation
import SwiftUI

enum TransactionMode {
    case buy, liquidate, editBuy, editLiquidate
    
    var titlePrefix: String? {
        switch self {
        case .buy: return "Adding"
        case .liquidate: return "Liquidating"
        case .editBuy, .editLiquidate: return nil
        }
    }
    
    var fullTitle: String? {
        switch self {
        case .editBuy, .editLiquidate: return "Edit Transaction"
        default: return nil
        }
    }
    
    var dateField: String {
        switch self {
        case .buy, .editBuy: return "Purchase Date"
        case .liquidate, .editLiquidate: return "Liquidate Date"
        }
    }
    
    var isEdit: Bool {
        switch self {
        case .editBuy, .editLiquidate, .liquidate: return true
        default: return false
        }
    }
}

struct TradeTransactionView: View {
    @Environment(\.di) private var di
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: TradeTransactionViewModel
    let transactionMode: TransactionMode
    let asset: Asset
    let portfolio: Portfolio?
    let transaction: Transaction?
    let holding: Holding?
        
    init(di: AppDI,
         transactionMode: TransactionMode,
         transaction: Transaction? = nil,
         holding: Holding? = nil,
         asset: Asset,
         currentPortfolioAt: Portfolio?
    ) {
        self.transactionMode = transactionMode
        self.asset = asset
        self.portfolio = currentPortfolioAt
        self.transaction = transaction
        self.holding = holding
        
        _viewModel = StateObject(
            wrappedValue: TradeTransactionViewModel(
                di: di,
                transactionMode: transactionMode,
                transaction: transaction,
                holding: holding,
                asset: asset,
                currentPortfolioAt: currentPortfolioAt
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
                .frame(height: 80)
                        
            VStack {
                FormRow(label: "Amount") {
                    TextField("0 \(viewModel.asset.assetType.unit)", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }
                
                Divider()
                    .padding(.vertical, 10)
                    .ignoresSafeArea(edges: .all)
                    .frame(maxWidth: .infinity)
                
                FormRow(label: "Price") {
                    HStack {
                        Text("Rp")
                        .foregroundStyle(.secondary)
                        TextField("3,800", text: $viewModel.priceText)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                    .ignoresSafeArea(edges: .all)
                    .frame(maxWidth: .infinity)
                                
                FormRow(label: "Platform") {
                    Menu {
                        ForEach(viewModel.platforms, id: \.persistentModelID) { platform in
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
                    .id(viewModel.platforms.map(\.persistentModelID))
                }
                
                Divider()
                    .padding(.vertical, 10)
                    .ignoresSafeArea(edges: .all)
                    .frame(maxWidth: .infinity)
                
                FormRow(label: "Portfolio") {
                    Menu {
                        ForEach(viewModel.portfolios, id: \.persistentModelID) { portfolio in
                            Button(portfolio.name) {
                                viewModel.portfolio = portfolio
                            }
                        }
                    } label: {
                        if viewModel.portfolio?.name == nil {
                            HStack {
                                Text("Select Portfolio")
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .tint(.black)
                            }
                        } else {
                            Text(viewModel.portfolio?.name ?? "")
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
                
                FormRow(label: transactionMode.dateField) {
                    HStack{
                        DatePicker("Date", selection: $viewModel.purchaseDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        Spacer()
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                    .ignoresSafeArea(edges: .all)
                    .frame(maxWidth: .infinity)
                    
            }
            .padding(EdgeInsets(top: 0, leading: 42, bottom: 0, trailing: 36))
            
            Spacer()
                        
            if (viewModel.transactionMode == .buy || viewModel.transactionMode == .liquidate) || ( [.editBuy, .editLiquidate].contains(viewModel.transactionMode) && viewModel.isDataFilled ) {
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
        .onAppear {
            viewModel.loadData()
        }
        .navigationBarTitle(transactionMode.fullTitle ?? "\(transactionMode.titlePrefix!) \(asset.assetType.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .padding(.bottom, 26)
        .navigationDestination(isPresented: $viewModel.didFinishTransaction) {
            PortfolioScreen(service: viewModel.portfolioService)
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

#Preview {
    let di = AppDI.preview
    let asset5 = Asset(
        assetType: .Crypto,
        symbol: "BTC",
        name: "Bitcoin",
        currency: .usd,
        country: "Outside Indonesia",
        lastPrice: 65000, // harga BTC dalam USD
        asOf: Date()
    )
    
//    TradeTransactionView(
//        di: .preview,
//        transactionMode: .buy,
//        asset: asset5,
//        transactionId: <#T##Transaction?#>
//    )
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
