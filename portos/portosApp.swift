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
    let container: ModelContainer = {
        let scheme = Schema([AppSource.self, Asset.self, Portfolio.self, Holding.self, Transaction.self])
        return try! ModelContainer(for: scheme)
    }()
    
    init() {
        #if DEBUG
        let key = "sseded.v1"
        if !UserDefaults.standard.bool(forKey: key) {
            let ctx = ModelContext(container)
            try? MockSeederV1(context: ctx).wipe()
            try? MockSeederV1(context: ctx).seed()
            UserDefaults.standard.set(true, forKey: key)
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
