//
//  ResponseModel.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import Foundation

// MARK: - API Response
struct APIResponse: Codable {
    let success: Bool
    let message: String
    let data: [APIAsset]
    let status: Int
}

// MARK: - API Response Get By ID
struct APIResponseGetByID: Codable {
    let success: Bool
    let message: String
    let data: APIAsset
    let status: Int
}

// MARK: - Asset
struct APIAsset: Codable, Identifiable {
    let id: String
    let symbol: String?
    let yTicker: String?
    let name: String?
    let exchange: String?
    let type: String?
    let currency: String?
    let country: String?
    let price: Double?
    let createdAt: APITimestamp
    let updatedAt: APITimestamp
}


// MARK: - Timestamp
struct APITimestamp: Codable {
    let seconds: Int
    let nanoseconds: Int

    enum CodingKeys: String, CodingKey {
        case seconds = "_seconds"
        case nanoseconds = "_nanoseconds"
    }
}

// MARK: - Timestamp helper
extension APITimestamp {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(seconds) + TimeInterval(nanoseconds) / 1_000_000_000)
    }
}

// MARK: - Enum parsing (contoh)
extension AssetType {
    init?(apiString: String) {
        switch apiString.uppercased() {
        case "CRYPTO": self = .Crypto
        case "STOCK", "EQUITY": self = .Stocks
        case "ETF": self = .ETF
        case "BOND": self = .Bonds
        case "MUTUALFUND", "MUTUAL_FUND", "MF": self = .MutualFunds
        default: return nil
        }
    }
}

extension Currency {
    init?(apiString: String) {
        switch apiString.uppercased() {
        case "USD": self = .usd
        case "IDR": self = .idr
        default: return nil
        }
    }
}

enum MappingError: Error, LocalizedError {
    case missingRequiredField(String)
    case invalidEnum(String, field: String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let f): return "Field wajib kosong: \(f)"
        case .invalidEnum(let v, let field): return "Nilai enum tidak dikenal '\(v)' untuk field \(field)"
        }
    }
}

struct AssetMapper {
    static func map(_ api: APIAsset) throws -> Asset {
        guard let symbol = api.yTicker, !symbol.isEmpty else {
            throw MappingError.missingRequiredField("symbol")
        }
        guard let name = api.name, !name.isEmpty else {
            throw MappingError.missingRequiredField("name")
        }
        guard let typeStr = api.type, let assetType = AssetType(apiString: typeStr) else {
            throw MappingError.invalidEnum(api.type ?? "nil", field: "type")
        }
        guard let currencyStr = api.currency, let currency = Currency(apiString: currencyStr) else {
            throw MappingError.invalidEnum(api.currency ?? "nil", field: "currency")
        }

        let country = api.country ?? ""
        let lastPrice = Decimal(api.price ?? 0)
        let asOf = api.updatedAt.date
        let assetId = api.id
        let yTicker = api.yTicker

        return Asset(
            assetType: assetType,
            symbol: symbol,
            name: name,
            currency: currency,
            country: country,
            lastPrice: lastPrice,
            asOf: asOf,
            assetId: assetId,
            yTicker: yTicker
        )
    }
}
