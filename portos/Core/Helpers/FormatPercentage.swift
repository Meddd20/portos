//
//  FormatPercentage.swift
//  portos
//
//  Created by Medhiko Biraja on 26/08/25.
//

import Foundation

extension Decimal {
    func formattedPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID") // pakai koma
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSDecimalNumber) ?? "-"
    }
    
    func formattedCash(_ formatter: NumberFormatter = Formatters.cashUS) -> String {
        formatter.string(from: self as NSDecimalNumber) ?? "0"
    }
    
    func cashFormatter(_ value: Double) -> String {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US")
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "0"
    }
}
