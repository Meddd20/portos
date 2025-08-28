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
    
//    func wipe() throws {
//        try context.deleteAll(Transaction.self)
//        try context.deleteAll(Holding.self)
//        try context.deleteAll(Asset.self)
//        try context.deleteAll(Portfolio.self)
//        try context.save()
//    }
    
    func seed() throws {
        let appBibit = AppSource(name: "Bibit")
        let appBareksa = AppSource(name: "Bareksa")
        let appStockbit = AppSource(name: "Stockbit")
        let appAjaib = AppSource(name: "Ajaib")
        let appIpot = AppSource(name: "IPOT")
        let appMiraeAsset = AppSource(name: "Mirae Asset Sekuritas")
        
        let appCryptoBinance = AppSource(name: "Binance")
        let appCryptoIndodax = AppSource(name: "Indodax")
        let appCryptoPluang = AppSource(name: "Pluang")
        let appTokocrypto = AppSource(name: "Tokocrypto")
        let appTriv = AppSource(name: "Triv")
        let appPintu = AppSource(name: "Pintu")
        let appCoinbase = AppSource(name: "Coinbase")
        
//        let asset1 = Asset(
//            assetType: .StocksId,
//            symbol: "BBCA",
//            name: "Bank Central Asia Tbk PT",
//            currency: .idr,
//            country: "Indonesia",
//            lastPrice: 9450, // contoh harga saham BBCA
//            asOf: Date()
//        )
//
//        let asset2 = Asset(
//            assetType: .StocksId,
//            symbol: "PANI",
//            name: "Pantai Indah Kapuk Dua Tbk PT",
//            currency: .idr,
//            country: "Indonesia",
//            lastPrice: 3100, // contoh harga saham PANI
//            asOf: Date()
//        )
//
//        let asset3 = Asset(
//            assetType: .MutualFunds,
//            symbol: "RDPU-BNIAM-DLS",
//            name: "BNI-AM Dana Lancar Syariah",
//            currency: .idr,
//            country: "Indonesia",
//            lastPrice: 1350, // NAB/UP reksa dana
//            asOf: Date()
//        )
//
//        let asset4 = Asset(
//            assetType: .MutualFunds,
//            symbol: "RDPU-SUCOR-MMF",
//            name: "Sucorinvest Money Market Fund",
//            currency: .idr,
//            country: "Indonesia",
//            lastPrice: 1275, // NAB/UP reksa dana
//            asOf: Date()
//        )
//
//        let asset5 = Asset(
//            assetType: .Crypto,
//            symbol: "BTC",
//            name: "Bitcoin",
//            currency: .usd,
//            country: "Outside Indonesia",
//            lastPrice: 65000, // harga BTC dalam USD
//            asOf: Date()
//        )
//        
//        let asset6 = Asset(
//            assetType: .Crypto,
//            symbol: "DOGE",
//            name: "Dogecoin",
//            currency: .usd,
//            country: "Outside Indonesia",
//            lastPrice: 0.12, // contoh harga DOGE dalam USD
//            asOf: Date()
//        )
//        
//        let asset7 = Asset(
//            assetType: .Stocks,
//            symbol: "AAPL",
//            name: "Apple Inc.",
//            currency: .usd,
//            country: "United States",
//            lastPrice: 225, // contoh harga AAPL (USD)
//            asOf: Date()
//        )
//
//        let asset8 = Asset(
//            assetType: .Stocks,
//            symbol: "NVDA",
//            name: "NVIDIA Corporation",
//            currency: .usd,
//            country: "United States",
//            lastPrice: 1150, // contoh harga NVDA (USD)
//            asOf: Date()
//        )
        [
            appBibit, appBareksa, appStockbit, appAjaib, appIpot, appMiraeAsset,
            appCryptoBinance, appCryptoIndodax, appCryptoPluang, appTokocrypto,
            appTriv, appPintu, appCoinbase
        ].forEach { context.insert($0) }
//        context.insert(asset1); context.insert(asset2); context.insert(asset3); context.insert(asset4); context.insert(asset5); context.insert(asset6);context.insert(asset7);context.insert(asset8);
        
        try context.save()
    }
}

extension ModelContext {
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items = try fetch(FetchDescriptor<T>())
        for item in items { delete(item) }
        try save()
    }
}
