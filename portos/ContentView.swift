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
    @State private var path = NavigationPath()
    
    var body: some View {
        let di = AppDI.live(modelContext: modelContext)
        NavigationStack(path: $path) {
            PortfolioScreen(service: di.portfolioService)
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

enum Route: Hashable {
    case trade
    case holding(Holding)
}
