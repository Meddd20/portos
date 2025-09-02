//
//  portosApp.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import SwiftUI
import SwiftData

@main
struct portosApp: App {
    private let container: ModelContainer
    private let di: AppDI
    
    init() {
        // build the SwiftData container
        let storeURL = URL.documentsDirectory.appending(path: "Portos.store")
        let cfg = ModelConfiguration(url: storeURL)
        let schema = Schema([AppSource.self, Asset.self, Portfolio.self, Holding.self, Transaction.self])
        container = try! ModelContainer(for: schema, configurations: cfg)
        
        // make a ModelContext
        let ctx = ModelContext(container)
        
        // build the DI using that context
        di = .live(modelContext: ctx)
        
        // run seed if needed
//        #if DEBUG
        runSeederIfNeeded(ctx: ctx)
//        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.di, di)
        }
        .modelContainer(container)
    }
}

//#if DEBUG
private func runSeederIfNeeded(ctx: ModelContext) {
    let key = "seeded.v1"
    if !UserDefaults.standard.bool(forKey: key) {
        Task { @MainActor in
//            try? MockSeederV1(context: ctx).wipe()
            try? MockSeederV1(context: ctx).seed()
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
//#endif
