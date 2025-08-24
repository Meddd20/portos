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
    @Published var didSave = false
    @Published var errorMessage: String?
    @Published var years: Int = 0
    
    let service: PortfolioService

    init(di: AppDI) {
        self.service = di.portfolioService
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
        
        let targetDate: Date = Calendar.current.date(byAdding: .year, value: years, to: .now) ?? .now

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
