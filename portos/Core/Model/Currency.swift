//
//  Currency.swift
//  portos
//
//  Created by Medhiko Biraja on 12/08/25.
//

import Foundation

enum Currency: String, CaseIterable, Codable {
    case usd = "USD" // US Dollar
    case eur = "EUR" // Euro
    case gbp = "GBP" // British Pound Sterling
    case jpy = "JPY" // Japanese Yen
    case cny = "CNY" // Chinese Yuan
    case aud = "AUD" // Australian Dollar
    case cad = "CAD" // Canadian Dollar
    case chf = "CHF" // Swiss Franc
    case hkd = "HKD" // Hong Kong Dollar
    case sgd = "SGD" // Singapore Dollar
    case idr = "IDR" // Indonesian Rupiah
    case inr = "INR" // Indian Rupee
    case krw = "KRW" // South Korean Won
    case thb = "THB" // Thai Baht
    case vnd = "VND" // Vietnamese Dong
    
    var symbol: String {
        switch self {
            case .usd: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            case .jpy: return "¥"
            case .cny: return "¥"
            case .aud: return "A$"
            case .cad: return "C$"
            case .chf: return "CHF"
            case .hkd: return "HK$"
            case .sgd: return "S$"
            case .idr: return "Rp"
            case .inr: return "₹"
            case .krw: return "₩"
            case .thb: return "฿"
            case .vnd: return "₫"
        }
    }
}
