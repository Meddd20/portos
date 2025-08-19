//
//  AddPortfolioSheet.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

struct AddPortfolioSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel : AddPortfolioViewModel
    
//    init(portfolioRepo: PortfolioRepositoryProtocol) {
//        _viewModel = StateObject(wrappedValue: AddPortfolioViewModel(repo: portfolioRepo))
//    }
    
    init (modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AddPortfolioViewModel(modelContext: modelContext))
    }

    var body: some View {
        VStack {
            NavigationStack {
                Form {
                    TextField("Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)

                    TextField("Target amount (IDR)", text: $viewModel.targetAmountText)
                        .keyboardType(.decimalPad)

                    DatePicker("Target date", selection: $viewModel.targetDate, displayedComponents: .date)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            viewModel.add()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
