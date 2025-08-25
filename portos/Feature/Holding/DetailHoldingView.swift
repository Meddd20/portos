//
//  DetailHoldingView.swift
//  portos
//
//  Created by Medhiko Biraja on 24/08/25.
//

import Foundation
import SwiftUI

struct DetailHoldingView: View {
    @Environment(\.di) private var di
    let holding: Holding
    @StateObject var viewModel: DetailHoldingViewModel
    @State private var navigateToLiquidateAsset: Bool = false
    @State private var navigateToTransferTransaction: Bool = false
    
    init(holding: Holding) {
        self.holding = holding
        _viewModel = StateObject(wrappedValue: DetailHoldingViewModel(holding: holding))
    }
    
    var body: some View {
        VStack {
            Text("\(holding.asset.name)")
            Text("\(holding.asset.symbol)")
            
            HStack {
                CircleButton(systemName: "plus", title: "History") {
                    
                }
                
                CircleButton(systemName: "minus", title: "Add") {
                    navigateToLiquidateAsset = true
                }
                
                CircleButton(systemName: "arrow.right", title: "More") {
                    navigateToTransferTransaction = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToLiquidateAsset) {
            TradeTransactionView(di: di, transactionMode: .liquidate, holding: holding, asset: holding.asset,  currentPortfolioAt: holding.portfolio)
        }
        .navigationDestination(isPresented: $navigateToTransferTransaction){
            TransferTransactionView(di: di, asset: holding.asset, transferMode: .transferToPortfolio, holding: holding)
        }
    }
}
