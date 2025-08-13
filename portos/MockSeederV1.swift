//
//  SeederV1.swift
//  portos
//
//  Created by Medhiko Biraja on 13/08/25.
//

import Foundation
import SwiftData

@MainActor
struct MockSeederV1 {
    let context: ModelContext
    
    func wipe() throws {
        try context.deleteAll(Transaction.self)
        try context.deleteAll(Holding.self)
        try context.deleteAll(Asset.self)
        try context.deleteAll(Portfolio.self)
        try context.save()
    }
    
    func seed() throws {
//        let app1 = try AppSource(name: "Bibit", iconPath: )
    }
}

extension ModelContext {
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items = try fetch(FetchDescriptor<T>())
        for item in items { delete(item) }
        try save()
    }
}
