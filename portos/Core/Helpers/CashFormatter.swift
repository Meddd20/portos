//
//  CashFormatter.swift
//  portos
//
//  Created by James Silaban on 24/08/25.
//

import Foundation

enum Formatters {
    static let cashUS: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US")
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
}

