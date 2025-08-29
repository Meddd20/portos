//
//  AddPortfolioSheet.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

enum ScreenMode {
    case add, edit
    
    var navTitle: String? {
        switch self {
        case .add: return "create_portfolio".localized
        case .edit: return "edit_portfolio_title".localized
        }
    }
    
    var buttonText: String {
        switch self {
        case .add: return "confirm".localized
        case .edit: return "save".localized
        }
    }
}

struct AddPortfolio: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    private var di: AppDI { AppDI.live(modelContext: modelContext) }
    let screenMode: ScreenMode
    
    @StateObject private var viewModel: AddPortfolioViewModel
    
    init(
        di: AppDI,
        screenMode: ScreenMode,
        portfolio: Portfolio? = nil,
        portfolioName: String = "",
        portfolioTargetAmount: String = ""
    ) {
        self.screenMode = screenMode
        
        _viewModel = StateObject(
            wrappedValue: AddPortfolioViewModel(
                di: di,
                screenMode: screenMode,
                portfolio: portfolio,
                portfolioName: portfolioName,
                portfolioTargetAmount: portfolioTargetAmount
            ))
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 1) {
                    row("title".localized) {
                        TextField("", text: $viewModel.name, prompt: Text("title".localized).foregroundStyle(Color.textPlaceholderApp))
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textPrimary)
                    }
                    
                    row("target_amount".localized) {
                        HStack {
                            if viewModel.targetAmountText != "" {
                                Text("currency_idr".localized)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.textPrimary)
                            }
                            TextField(
                                "",
                                text: $viewModel.targetAmountText,
                                prompt: Text("type_amount".localized)
                                    .foregroundStyle(Color.textPlaceholderApp)
                            )
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textPrimary)
                            .keyboardType(.numberPad)
                        }
                    }
                    
                    row("term".localized) {
                        HStack {
                            TextField("",
                                      text: Binding(
                                              get: { String(viewModel.years) },
                                              set: { viewModel.years = Int($0) ?? 0 }
                                          ))
                                .font(.system(size: 15))
                            Text("years".localized)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Stepper("", value: $viewModel.years, in: 0...100)
                                .labelsHidden()
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding(.horizontal, 50)
                .padding(.top, 168)
                
                Spacer()
                
                Button(screenMode.buttonText) {
                    if screenMode == .add {
                        viewModel.add()
                    } else {
                        viewModel.saveEdit()
                    }
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.ctaEnabledText)
                .background(
                    (viewModel.name.isEmpty || viewModel.targetAmountText.isEmpty)
                    ? Color.ctaDisabledBackground
                    : Color.ctaEnabledBackground
                )
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                .opacity((viewModel.name.isEmpty || viewModel.targetAmountText.isEmpty) ? 0.9 : 1.0)
            }
            .background(
                LinearGradient(
                stops: [
                    Gradient.Stop(color: Color.backgroundPrimary, location: 0.13),
                    Gradient.Stop(color: Color.backgroundApp, location: 0.26), ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1) ))
            .navigationBarBackButtonHidden()
            .navigationTitle(screenMode.navTitle ?? "default")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundApp, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {dismiss()}) {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(Color.textPrimary)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func row<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
                .fontWeight(.semibold)
                .font(.system(size: 15))
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        Divider()
    }
}
