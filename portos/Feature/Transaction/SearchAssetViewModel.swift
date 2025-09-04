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

@MainActor
class SearchAssetViewModel: ObservableObject {
    @Published var searchTerms: String = ""
    @Published var assets: [Asset] = []
    @Published var assetPosition: [AssetPosition] = []
    @Published var searchRes: APIResponse?
    @Published var errorMessage: String?
    
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
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func loadAssets() {
        ApiService.fetchAssets { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let response):
                    let mapped: [Asset] = response.data.compactMap { api in
                        do {
                            
                            return try AssetMapper.map(api)
                        }
                        catch {
                            print("Map failed at: \(api.symbol ?? "nil"): \(error.localizedDescription)")
                            return nil
                        }
                    }
                    self?.assets = mapped
                    self?.errorMessage = nil

                case .failure(let err):
                    self?.assets = []
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func mapError(_ error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid URL"
        case .decodingFailed:
            return "Decoding Failed"
        case .requestFailed:
            return "Request Failed"
        case .unknown:
            return "Unknown Error"
        case .httpError:
            return "HTTP Error"
        case .apiFailed:
            return "API Failed"
        }
    }
}
