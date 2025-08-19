//
//  App.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class AppSource {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconPath: String
    
    @Relationship(deleteRule: .cascade, inverse: \Holding.app)
    var holdings: [Holding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.app)
    var transactions: [Transaction] = []
    
    init(name: String, iconPath: String) {
        self.id = UUID()
        self.name = name
        self.iconPath = iconPath
    }
}
