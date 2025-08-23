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
        
        let asset1 = Asset(
            assetType: .Stocks,
            symbol: "BBCA",
            name: "Bank Central Asia Tbk PT",
            currency: .idr,
            country: "Indonesia",
            lastPrice: 9450, // contoh harga saham BBCA
            asOf: Date()
        )

        let asset2 = Asset(
            assetType: .Stocks,
            symbol: "PANI",
            name: "Pantai Indah Kapuk Dua Tbk PT",
            currency: .idr,
            country: "Indonesia",
            lastPrice: 3100, // contoh harga saham PANI
            asOf: Date()
        )

        let asset3 = Asset(
            assetType: .MutualFunds,
            symbol: "RDPU-BNIAM-DLS",
            name: "BNI-AM Dana Lancar Syariah",
            currency: .idr,
            country: "Indonesia",
            lastPrice: 1350, // NAB/UP reksa dana
            asOf: Date()
        )

        let asset4 = Asset(
            assetType: .MutualFunds,
            symbol: "RDPU-SUCOR-MMF",
            name: "Sucorinvest Money Market Fund",
            currency: .idr,
            country: "Indonesia",
            lastPrice: 1275, // NAB/UP reksa dana
            asOf: Date()
        )

        let asset5 = Asset(
            assetType: .Crypto,
            symbol: "BTC",
            name: "Bitcoin",
            currency: .usd,
            country: "Outside Indonesia",
            lastPrice: 65000, // harga BTC dalam USD
            asOf: Date()
        )
        
        let asset6 = Asset(
            assetType: .Crypto,
            symbol: "DOGE",
            name: "Dogecoin",
            currency: .usd,
            country: "Outside Indonesia",
            lastPrice: 0.12, // contoh harga DOGE dalam USD
            asOf: Date()
        )
        
        let portfolio1 = Portfolio(
            name: "Retirement",
            targetAmount: Decimal(12_000_000_000),
            targetDate: Date(),
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let portfolio2 = Portfolio(
            name: "Having Fun",
            targetAmount: Decimal(1_000_000_000),
            targetDate: Date(),
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let holding1 = Holding(
            asset: asset4,
            portfolio: portfolio1,
            quantity: Decimal(4_000_000),
            averagePricePerUnit: Decimal(100_000),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let holding2 = Holding( // BBCA via Stockbit
            asset: asset1,
            portfolio: portfolio1,
            quantity: Decimal(20),                  // shares
            averagePricePerUnit: Decimal(9_000),    // IDR
            createdAt: Date(),
            updatedAt: Date()
        )

        let holding3 = Holding(
            asset: asset5,
            portfolio: portfolio1,
            quantity: Decimal(0.020),               // BTC
            averagePricePerUnit: Decimal(60_000),   // USD
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let holding7 = Holding(
            asset: asset2,
            portfolio: portfolio1,
            quantity: Decimal(100),                  // shares
            averagePricePerUnit: Decimal(9_000),    // IDR
            createdAt: Date(),
            updatedAt: Date()
        )

        let holding4 = Holding( // DOGE via Binance
            asset: asset6,
            portfolio: portfolio2,
            quantity: Decimal(1_000),               // coins
            averagePricePerUnit: Decimal(0.12),     // USD
            createdAt: Date(),
            updatedAt: Date()
        )

        let holding5 = Holding( // PANI via Stockbit
            asset: asset2,
            portfolio: portfolio2,
            quantity: Decimal(5),
            averagePricePerUnit: Decimal(3_000),    // IDR
            createdAt: Date(),
            updatedAt: Date()
        )

        let holding6 = Holding( // BNI-AM Dana Lancar Syariah via Bibit
            asset: asset3,
            portfolio: portfolio2,
            quantity: Decimal(2_500_000),
            averagePricePerUnit: Decimal(100_000),  // example NAV/unit
            createdAt: Date(),
            updatedAt: Date()
        )
        
        [
            appBibit, appBareksa, appStockbit, appAjaib, appIpot, appMiraeAsset,
            appCryptoBinance, appCryptoIndodax, appCryptoPluang, appTokocrypto,
            appTriv, appPintu, appCoinbase
        ].forEach { context.insert($0) }
        context.insert(asset1); context.insert(asset2); context.insert(asset3); context.insert(asset4); context.insert(asset5); context.insert(asset6)
        context.insert(portfolio1); context.insert(portfolio2)
        context.insert(holding1); context.insert(holding2); context.insert(holding3); context.insert(holding4); context.insert(holding5); context.insert(holding6); context.insert(holding7)
        
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










////
////  SeederV1.swift
////  portos
////
////  Created by Medhiko Biraja on 13/08/25.
////
//
//import Foundation
//import SwiftData
//
//@MainActor
//struct MockSeederV1 {
//    let context: ModelContext
//    
//    func wipe() throws {
//        try context.deleteAll(Transaction.self)
//        try context.deleteAll(Holding.self)
//        try context.deleteAll(Asset.self)
//        try context.deleteAll(Portfolio.self)
//        try context.save()
//    }
//    
//    func seed() throws {
//        let app1 = AppSource(
//            name: "Bibi//
//        )
//        
//        let app2 = AppSource(
//            name: "Stockbit",
//            iconPath: "stockbit"
//        )
//        
//        let app3 = AppSource(
//            name: "Binance",
//            iconPath: "binance"
//        )
//        
//        let asset1 = Asset(
//            assetType: .Stocks,
//            symbol: "BBCA",
//            name: "Bank Central Asia Tbk PT",
//            currency: .idr,
//            country: "Indonesia"
//        )
//        
//        let asset2 = Asset(
//            assetType: .Stocks,
//            symbol: "PANI",
//            name: "Pantai Indah Kapuk Dua Tbk PT",
//            currency: .idr,
//            country: "Indonesia"
//        )
//        
//        let asset3 = Asset(
//            assetType: .MutualFunds,
//            symbol: "RDPU-BNIAM-DLS",
//            name: "BNI-AM Dana Lancar Syariah",
//            currency: .idr,
//            country: "Indonesia"
//        )
//        
//        let asset4 = Asset(
//            assetType: .MutualFunds,
//            symbol: "RDPU-SUCOR-MMF",
//            name: "Sucorinvest Money Market Fund",
//            currency: .idr,
//            country: "Indonesia"
//        )
//        
//        let asset5 = Asset(
//            assetType: .Crypto,
//            symbol: "BTC",
//            name: "Bitcoin",
//            currency: .usd,
//            country: "Outside Indonesia"
//        )
//        
//        let asset6 = Asset(
//            assetType: .Crypto,
//            symbol: "DOGE",
//            name: "Dogecoin",
//            currency: .usd,
//            country: "Outside Indonesia"
//        )
//        
//        let portfolio1 = Portfolio(
//            name: "Retirement",
//            targetAmount: Decimal(12_000_000_000),
//            targetDate: Date(),
//            currentPortfolioValue: Decimal(50_000),
//            isActive: true,
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//        
////        let portfolio2 = Portfolio(
////            name: "Having Fun",
////            targetAmount: Decimal(1_000_000_000),
////            targetDate: Date(),
////            currentPortfolioValue: Decimal(1_000_000),
////            isActive: true,
////            createdAt: Date(),
////            updatedAt: Date()
////        )
//        
//        let holding1 = Holding(
//            app: app1,
//            asset: asset4,
//            portfolio: portfolio1,
//            quantity: Decimal(50),
//            averagePricePerUnit: Decimal(1_000),
//            lastUpdatedPrice: Decimal(2_000), // harga hari ini = 50 x 2000 = 100_000
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//        
////        let holding2 = Holding( // BBCA via Stockbit
////            app: app2,
////            asset: asset1,
////            portfolio: portfolio1,
////            quantity: Decimal(20),                  // shares
////            averagePricePerUnit: Decimal(9_000),    // IDR
////            lastUpdatedPrice: Decimal(9_250),
////            createdAt: Date(),
////            updatedAt: Date()
////        )
////
////        let holding3 = Holding( // BTC via Binance (priced in USD per your Asset.currency)
////            app: app3,
////            asset: asset5,
////            portfolio: portfolio1,
////            quantity: Decimal(0.020),               // BTC
////            averagePricePerUnit: Decimal(60_000),   // USD
////            lastUpdatedPrice: Decimal(62_500),
////            createdAt: Date(),
////            updatedAt: Date()
////        )
//
////        let holding4 = Holding( // DOGE via Binance
////            app: app3,
////            asset: asset6,
////            portfolio: portfolio2,
////            quantity: Decimal(1_000),               // coins
////            averagePricePerUnit: Decimal(0.12),     // USD
////            lastUpdatedPrice: Decimal(0.15),
////            createdAt: Date(),
////            updatedAt: Date()
////        )
//
////        let holding5 = Holding( // PANI via Stockbit
////            app: app2,
////            asset: asset2,
////            portfolio: portfolio2,
////            quantity: Decimal(5),
////            averagePricePerUnit: Decimal(3_000),    // IDR
////            lastUpdatedPrice: Decimal(3_200),
////            createdAt: Date(),
////            updatedAt: Date()
////        )
//
////        let holding6 = Holding( // BNI-AM Dana Lancar Syariah via Bibit
////            app: app1,
////            asset: asset3,
////            portfolio: portfolio2,
////            quantity: Decimal(2_500_000),
////            averagePricePerUnit: Decimal(100_000),  // example NAV/unit
////            lastUpdatedPrice: Decimal(101_500),
////            createdAt: Date(),
////            updatedAt: Date()
////        )
//        
//        context.insert(app1); context.insert(app2); context.insert(app3)
//        context.insert(asset1); context.insert(asset2); context.insert(asset3); context.insert(asset4); context.insert(asset5); context.insert(asset6)
//        context.insert(portfolio1)
////        ; context.insert(portfolio2)
//        context.insert(holding1)
////        ; context.insert(holding2); context.insert(holding3); context.insert(holding4); context.insert(holding5); context.insert(holding6)
//        
//        try context.save()
//    }
//}
//
//extension ModelContext {
//    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
//        let items = try fetch(FetchDescriptor<T>())
//        for item in items { delete(item) }
//        try save()
//    }
//}
