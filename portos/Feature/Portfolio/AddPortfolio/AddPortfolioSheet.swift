//
//  AddPortfolioSheet.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

struct AddPortfolio: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    private var di: AppDI { AppDI.live(modelContext: modelContext) }
    
    @StateObject private var viewModel: AddPortfolioViewModel
    
    init(di: AppDI) {
        _viewModel = StateObject(wrappedValue: AddPortfolioViewModel(di: di))
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 1) {
                    row("Title") {
                        TextField("Title", text: $viewModel.name)
                            .font(.system(size: 15))
                    }
                    
                    row("Target Amount") {
                        TextField("Type Amount...", text: $viewModel.targetAmountText)
                            .font(.system(size: 15))
                            .keyboardType(.numberPad)
                    }
                    
                    row("Term") {
                        HStack {
                            Text("\(viewModel.years)")
                                .font(.system(size: 15))
                            Text("Years")
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
                
                Button("Confirm") {
                    viewModel.add()
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                .clipShape(Capsule())
                .padding(.horizontal, 40)
            }
            .navigationBarBackButtonHidden()
            .navigationTitle("Create portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {dismiss()}) {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.black)
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

#Preview {
    let di = AppDI.preview
    
    AddPortfolio(di: .preview)
}
