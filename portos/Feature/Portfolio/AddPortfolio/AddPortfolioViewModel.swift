//
//  AddPortfolioViewModel.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import Foundation
import SwiftData

@MainActor
final class AddPortfolioViewModel: ObservableObject {
    @Published var name = ""
    @Published var targetAmountText = ""
    @Published var targetDate: Date = .now
    @Published var didSave = false
    @Published var errorMessage: String?
    
    private let service: PortfolioService

    init(service: PortfolioService) {
        self.service = service
    }
    
    private var targetAmount: Decimal? {
        Decimal(string: targetAmountText.replacingOccurrences(of: ",", with: "."))
    }
    
    func add() {
        guard let target = targetAmount else {
            self.errorMessage = "Target amount is required"
            print("ERROR: target amount missing")
            return
        }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.errorMessage = "Name is required"
            print("ERROR: name empty")
            return
        }
        
        do {
            try service.createPortfolio(name: trimmed, targetAmount: target, targetDate: targetDate)
            self.didSave = true
            self.errorMessage = nil
            print("add portfolio - save success")
        }
        catch {
            self.errorMessage = "Save failed: \(error.localizedDescription)"
            self.didSave = false
            print("add portfolio - error: \(error)")
        }
        
        print("add portfolio - save")
    }
}
