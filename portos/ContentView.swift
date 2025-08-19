//
//  ContentView.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @StateObject private var diContainer = DIContainer()
    
    var body: some View {
        PortfolioScreen()
//            .environment(\.diContainer, diContainer)
//            .onAppear {
//                setupDependencyInjection()
//            }
    }
    
//    private func setupDependencyInjection() {
//        // Inject ModelContext ke DIContainer
//        diContainer.setModelContext(modelContext)
//    }

}

#Preview {
    ContentView()
}
