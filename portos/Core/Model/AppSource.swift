//
//  AppSource.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class AppSource: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.app)
    var transactions: [Transaction] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
