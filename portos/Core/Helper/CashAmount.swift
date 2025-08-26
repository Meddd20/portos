//
//  CashAmount.swift
//  portos
//
//  Created by James Silaban on 24/08/25.
//

import Foundation

func cashAmount(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "id_ID") // Indonesian format
    formatter.numberStyle = .currency
    formatter.currencyCode = "IDR"                 // use IDR
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    
    return formatter.string(from: value as NSDecimalNumber) ?? "Rp 0"
}
