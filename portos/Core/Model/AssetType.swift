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
    case StocksId
    case Crypto
    case ETF
    
    var multiplier: Int {
        switch self {
        case .StocksId:
            return 100
        default:
            return 1
        }
    }
    
    var unit: String {
        switch self {
        case .Bonds: return "Nominal"
        case .Crypto: return "Coins"
        case .ETF: return "Unit(s)"
        case .MutualFunds: return "Unit(s)"
        case .Options: return "Contract(s)"
        case .Stocks: return "Share(s)"
        case .StocksId: return "Lot"
        }
    }
    
    var displayName: String {
        switch self {
        case .Bonds: return "Bonds"
        case .Stocks: return "Stocks"
        case .StocksId: return "Indonesian Stocks"
        case .Crypto: return "Crypto"
        case .MutualFunds: return "Mutual Funds"
        case .Options: return "Options"
        case .ETF: return "ETF"
        }
    }
}
