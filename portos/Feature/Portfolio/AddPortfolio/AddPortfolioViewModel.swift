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
    
    @Published var error: String?
    
    private let modelContext: ModelContext
    
//    private let repo: PortfolioRepositoryProtocol
//    
//    init(repo: PortfolioRepositoryProtocol) {
//        self.repo = repo
//    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    
    private var targetAmount: Decimal? {
        Decimal(string: targetAmountText.replacingOccurrences(of: ",", with: "."))
    }
    
//    func add(name: String, targetAmount: Decimal?, targetDate: Date)
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
//            let p = try repo.create(
//                name: trimmed,
//                targetAmount: target,
//                targetDate: targetDate
//            )
            let p = Portfolio(name: trimmed, targetAmount: target, targetDate: targetDate, totalAmount: 0, isActive: true, createdAt: .now, updatedAt: .now)
            
            modelContext.insert(p)
            
            try modelContext.save()
            
            self.didSave = true
            self.errorMessage = nil
            print(p)
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
