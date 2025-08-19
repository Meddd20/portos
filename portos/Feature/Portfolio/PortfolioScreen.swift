//
//  PortfolioScreen.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

struct PortfolioScreen: View {
    @Environment(\.diContainer) private var diContainer
    @Environment(\.modelContext) private var modelContext
//    let repo = PortfolioRepository(ctx: modelContext)

    @StateObject private var viewModel: PortfolioViewModel
    init() {
        // Temporary initialization dengan mock - akan di-replace di onAppear
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(repo: MockPortfolioRepository()))
    }


    @State private var selection: Portfolio?
    @State private var selectionID: UUID? = nil
    
    @State private var selectedIndex: Int = 0
    
    @Query(sort: \Portfolio.createdAt) var portfolios: [Portfolio]
    @Query(
        filter: #Predicate<Holding> { $0.porfolio.name == "x" }
    ) var holdings: [Holding]
    
    @State private var showingAdd = false
    
    var body: some View {
        VStack(alignment: .leading) {
            PickerSegmented(
                selectedIndex: $selectedIndex,
                titles: portfolios.map { $0.name }
            )
            
            Spacer().frame(height: 100)
            
            CircleButton(systemName: "plus", title: "Add", action: { showingAdd = true }
            )
            .padding(.bottom, 20)
            
            
            Text("next")
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .sheet(isPresented: $showingAdd) {
            AddPortfolioSheet(modelContext: modelContext)
        }
//        .onAppear {
//            setupDependencies()
//        }
    }
}

#Preview {
    PortfolioScreen()
}
