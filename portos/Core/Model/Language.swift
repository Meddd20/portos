//
//  Language.swift
//  portos
//
//  Created by James Silaban on 27/08/25.
//

enum Language: String, CaseIterable {
    case indonesia = "id"
    case english = "en"
    var displayName: String {
        switch self {
        case .indonesia: return "Indonesia"
        case .english: return "English"
        }
    }
}
