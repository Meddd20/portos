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
        PortfolioScreen(service: di.portfolioService)
    }
}

#Preview {
    ContentView()
}
