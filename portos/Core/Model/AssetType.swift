//
//  AssetType.swift
//  portos
//
//  Created by Medhiko Biraja on 13/08/25.
//

import Foundation

enum AssetType: String, Codable{
    case Bonds
    case Options
    case MutualFunds
    case Stocks
    case Crypto
    case ETF
}

extension AssetType {
    var displayName: String {
        switch self {
        case .Bonds: return "Bonds"
        case .Stocks: return "Stocks"
        case .Crypto: return "Crypto"
        case .MutualFunds: return "Mutual Funds"
        case .Options: return "Options"
        case .ETF: return "ETF"
        }
    }
}
