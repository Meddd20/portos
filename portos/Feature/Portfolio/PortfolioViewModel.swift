//
//  PortfolioViewModel.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import Foundation
import SwiftData

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var portfolios: [Portfolio] = []
    @Published var error: String?
    
    private let repo: any PortfolioRepositoryProtocol
    
    init(repo: PortfolioRepositoryProtocol) {
        self.repo = repo
    }

    func load() {
        do { portfolios = try repo.allPortfolios() }
        catch { self.error = error.localizedDescription }
    }

    func archive(_ portfolio: Portfolio) {
        do {
            try repo.setActive(portfolio, false)
            load()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
