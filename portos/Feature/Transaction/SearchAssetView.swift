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
    @StateObject private var viewModel: SearchAssetViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
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
                            .foregroundStyle(Color.textPrimary)
                        
                        Divider()
                            .padding(.vertical, 10)
                            .ignoresSafeArea(edges: .all)
                            .frame(maxWidth: .infinity)
                        
                        ForEach (assetPosition.holdings, id: \.persistentModelID) { holding in
                            Button {
                                navigationManager.push(.buyAsset(asset: holding.asset, portfolio: portfolio, fromSearch: true))
                            } label: {
                                HStack {
                                    Text("\(holding.asset.symbol)")
                                        .font(.system(size: 16))
                                        .frame(width: 106, alignment: .leading)
                                        .foregroundStyle(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(holding.asset.name)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(width: 165, alignment: .trailing)
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            
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
                            .foregroundStyle(Color.textPrimary)
                        
                        Divider()
                            .padding(.vertical, 10)
                            .ignoresSafeArea(edges: .all)
                            .frame(maxWidth: .infinity)
                        
                        ForEach(section.assets, id: \.id) { asset in
                            Button {
                                let selected = asset
                                    // Tutup search UI manual
                                    viewModel.searchTerms = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                    to: nil, from: nil, for: nil)

                                    DispatchQueue.main.async {
                                        navigationManager.push(.buyAsset(asset: selected, portfolio: portfolio, fromSearch: true))
                                    }
                            } label: {
                                HStack {
                                    Text(asset.symbol)
                                        .font(.system(size: 16))
                                        .frame(width: 106, alignment: .leading)
                                        .foregroundStyle(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(asset.name)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(width: 165, alignment: .trailing)
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            
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
            .padding(.bottom, 100)
        }
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color.backgroundPrimary, location: 0.13),
                    Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1) ))
        .searchable(
            text: $viewModel.searchTerms,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search"
        )
        .navigationTitle("Choose asset to add")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.getAllHoldings()
            viewModel.loadAssets()
        }
        .toolbar {
            ToolbarItem (placement: .topBarLeading) {
                Button (action: {
                    navigationManager.popLast()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .toolbarBackground(Color.backgroundApp, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
