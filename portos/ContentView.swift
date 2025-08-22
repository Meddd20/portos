//
//  ContentView.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let di = AppDI.live(modelContext: modelContext)
        NavigationStack {
            PortfolioScreen(service: di.portfolioService)
//            TradeTransactionView(di: di, transactionMode: .buy)
        }

    }
}

#Preview {
    ContentView()
}

extension Portfolio {
    static var dummy: Portfolio {
        Portfolio(
            name: "Dummy Portfolio",
            targetAmount: 100_000,
            targetDate: .now,
            isActive: true,
            createdAt: .now,
            updatedAt: .now
        )
    }
}

extension AppSource {
    static var dummy: AppSource {
        AppSource(name: "Bibit")
    }
}
