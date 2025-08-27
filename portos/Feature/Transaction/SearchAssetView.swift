//
//  SearchAssetView.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation
import SwiftUI

struct SearchAssetView: View {
    @Environment(\.di) private var di
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SearchAssetViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var navigateToAddView = false
    let portfolio: Portfolio?
    
    init(di: AppDI, currentPortfolioAt: Portfolio? = nil) {
        self.portfolio = currentPortfolioAt
        _viewModel = StateObject(
            wrappedValue: SearchAssetViewModel(di: di, currentPortfolioAt: currentPortfolioAt)
        )
    }
    
    var body: some View {
        ScrollView{
            LazyVStack {
                if viewModel.searchTerms.isEmpty {
                    Spacer()
                        .frame(height: 30)
                    
                    ForEach (Array(viewModel.assetPosition.enumerated()), id: \.element.id) { index, assetPosition in
                        Text("\(assetPosition.group)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, index == 0 ? 5 : 22)
                            .fontWeight(.semibold)
                        
                        Divider()
                            .padding(.vertical, 10)
                            .ignoresSafeArea(edges: .all)
                            .frame(maxWidth: .infinity)
                        
                        ForEach (assetPosition.holdings, id: \.persistentModelID) { holding in
                            NavigationLink{
                                TradeTransactionView(di: di, transactionMode: .buy, asset: holding.asset, currentPortfolioAt: portfolio ?? nil)
                            } label: {
                                HStack {
                                    Text("\(holding.asset.symbol)")
                                        .font(.system(size: 16))
                                        .frame(width: 106, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Text(holding.asset.name)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(width: 165, alignment: .trailing)
                                    
                                    
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.primary)
                            
                            Divider()
                                .padding(.vertical, 10)
                                .ignoresSafeArea(edges: .all)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    Spacer()
                    
                    
                } else {
                    ForEach(viewModel.filterAssetSection, id: \.id) {section in
                        Text(section.type.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 22)
                            .fontWeight(.semibold)
                        
                        Divider()
                            .padding(.vertical, 10)
                            .ignoresSafeArea(edges: .all)
                            .frame(maxWidth: .infinity)
                        
                        ForEach(section.assets, id: \.id) { asset in
                            Button {
                                navigationManager.push(.buyAsset(asset: asset, portfolio: portfolio), back: .popToRoot)
                            } label: {
                                HStack {
                                    Text(asset.symbol)
                                        .font(.system(size: 16))
                                        .frame(width: 106, alignment: .leading)
                                    
                                    Spacer()
                                                                        
                                    Text(asset.name)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(width: 165, alignment: .trailing)
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.primary)
                            
                            Divider()
                                .padding(.vertical, 10)
                                .ignoresSafeArea(edges: .all)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 20)
            .padding(.trailing, 26)
            .navigationTitle("Choose asset to add")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.getAllHoldings()
                viewModel.loadAssets()
            }
            .navigationBarBackButtonHidden(true)
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
            .background(
                LinearGradient(
                stops: [
                    Gradient.Stop(color: .white, location: 0.13),
                    Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1) ))
        }
        .searchable(
            text: $viewModel.searchTerms,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search"
        )
        
    }
    @ViewBuilder
    private var holdingsContent: some View {
        ForEach(Array(viewModel.assetPosition.enumerated()), id: \.element.id) { index, assetPosition in
            assetPositionSection(assetPosition: assetPosition, isFirst: index == 0)
        }
    }
    
    @ViewBuilder
    private var searchResultsContent: some View {
        ForEach(viewModel.filterAssetSection, id: \.id) { section in
            assetSection(section: section)
        }
        Spacer()
    }
    
    @ViewBuilder
    private func assetPositionSection(assetPosition: AssetPosition, isFirst: Bool) -> some View {
        sectionHeader(title: assetPosition.group, isFirst: isFirst)
        
        ForEach(assetPosition.holdings, id: \.persistentModelID) { holding in
            assetRow(
                symbol: holding.asset.symbol,
                name: holding.asset.name,
                asset: holding.asset
            )
        }
    }
    
    @ViewBuilder
    private func assetSection(section: AssetSection) -> some View {
        sectionHeader(title: section.type.displayName, isFirst: false)
        
        ForEach(section.assets, id: \.id) { asset in
            assetRow(
                symbol: asset.symbol,
                name: asset.name,
                asset: asset
            )
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: String, isFirst: Bool) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, isFirst ? 5 : 22)
                .fontWeight(.semibold)
            
            Divider()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func assetRow(symbol: String, name: String, asset: Asset) -> some View {
        VStack(spacing: 10) {
            NavigationLink {
                TradeTransactionView(
                    di: di,
                    transactionMode: .buy,
                    asset: asset,
                    currentPortfolioAt: portfolio
                )
            } label: {
                HStack(alignment: .center) {
                    Text(symbol)
                        .font(.system(size: 16))
                        .frame(width: 106, alignment: .leading)
                    
                    Spacer()
                    
                    Text(name)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 165, alignment: .trailing)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            
            Divider()
                .padding(.vertical, 10)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity)
        }
    }
}
