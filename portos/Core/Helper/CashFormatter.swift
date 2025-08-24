//
//  CashFormatter.swift
//  portos
//
//  Created by James Silaban on 24/08/25.
//

import Foundation

func cashFormatter(_ value: Double) -> String {
    let f = NumberFormatter()
    f.locale = Locale(identifier: "id_ID")
    f.numberStyle = .decimal
    f.usesGroupingSeparator = true
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 2
    return f.string(from: NSNumber(value: value)) ?? "0"
}
