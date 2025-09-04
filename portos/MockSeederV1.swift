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
        
        [
            appBibit, appBareksa, appStockbit, appAjaib, appIpot, appMiraeAsset,
            appCryptoBinance, appCryptoIndodax, appCryptoPluang, appTokocrypto,
            appTriv, appPintu, appCoinbase
        ].forEach { context.insert($0) }
        
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
