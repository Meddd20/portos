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
//    private let di = AppDI.live()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Portfolio.self, Holding.self, Transaction.self])
        }
//        .modelContainer(di.container)
        
    }
}
