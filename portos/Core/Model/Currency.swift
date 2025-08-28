//
//  Currency.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation

enum Currency: String, CaseIterable, Codable {
    case usd = "USD" // US Dollar
    case idr = "IDR" // Indonesian Rupiah
    
    var symbol: String {
        switch self {
            case .usd: return "$"
            case .idr: return "Rp"
        }
    }
}
