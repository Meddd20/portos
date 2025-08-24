//
//  SearchAssetViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 23/08/25.
//

import Foundation
import SwiftUI

struct AssetSection: Identifiable {
    let id = UUID()
    let type: AssetType
    let assets: [Asset]
}

class SearchAssetViewModel: ObservableObject {
    @Published var searchTerms: String = ""
    @Published var assets: [Asset] = []
    @Published var assetPosition: [AssetPosition] = []
    
    var filteredAssets: [Asset] {
        assets.filter { $0.name.localizedCaseInsensitiveContains(searchTerms) || $0.symbol.localizedCaseInsensitiveContains(searchTerms)}
    }
    
    var filterAssetSection: [AssetSection] {
        let filtered = assets.filter {
            searchTerms.isEmpty || $0.name.localizedCaseInsensitiveContains(searchTerms) || $0.symbol.localizedCaseInsensitiveContains(searchTerms)
        }
        
        let grouped = Dictionary(grouping: filtered, by: { $0.assetType })
        
        return grouped.map { AssetSection(type: $0.key, assets: $0.value) }
    }
            
    private let portfolioService: PortfolioService
    private let assetRepository: AssetRepository
    let currentPortfolioAt: Portfolio?
    
    init(di: AppDI, currentPortfolioAt: Portfolio?) {
        self.portfolioService = di.portfolioService
        self.assetRepository = di.assetRepository
        self.currentPortfolioAt = currentPortfolioAt
    }
    
    func getAllHoldings() {
        do {
            assetPosition = try portfolioService.getHoldings(portfolioName: "All")
        } catch {
            print("")
        }
    }
    
    func getAllAssets() {
        do {
            assets = try assetRepository.getAllAsset()
            print(assets.count)
        } catch {
            print("")
        }
    }
    
}
