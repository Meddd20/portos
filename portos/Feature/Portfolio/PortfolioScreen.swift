//
//  PortfolioScreen.swift
//  portos
//
//  Created by Niki Hidayati on 13/08/25.
//

import SwiftUI
import SwiftData

struct PortfolioScreen: View {
    @Environment(\.modelContext) private var modelContext
    private var di: AppDI { AppDI.live(modelContext: modelContext) }
    
    @StateObject private var viewModel: PortfolioViewModel
    
    init(service: PortfolioService) {
        _viewModel = StateObject(wrappedValue: PortfolioViewModel(service: service))
    }

    @State private var selection: Portfolio?
    @State private var selectionID: UUID? = nil
    @State private var selectedIndex: Int = 0
    @State private var showingAdd = false
    
    @Query(sort: \Portfolio.createdAt) var portfolios: [Portfolio]
    @Query(
        filter: #Predicate<Holding> { $0.portfolio.name == "x" }
    ) var holdings: [Holding]
    
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
            AddPortfolioSheet(service: di.portfolioService)
        }
    }
}


//struct PortfolioScreen_PreviewWrapper: View {
//    @Environment(\.modelContext) private var modelContext
//
//    var body: some View {
//        let di = AppDI.live(modelContext: modelContext)
//        PortfolioScreen(service: di.portfolioService)
//    }
//}
//
//#Preview {
//    PortfolioScreen_PreviewWrapper()
//}
