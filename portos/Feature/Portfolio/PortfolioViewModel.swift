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
    
    private let service: PortfolioService

    init(service: PortfolioService) {
        self.service = service
    }

    func load() {
        do { portfolios = try service.getAllPortfolios() }
        catch { self.error = error.localizedDescription }
    }
}
