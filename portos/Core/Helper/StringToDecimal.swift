//
//  StringToDecimal.swift
//  portos
//
//  Created by Niki Hidayati on 24/08/25.
//

import Foundation

enum ParseDecimalError: LocalizedError {
    case invalidNumber
    var errorDescription: String? { "Nominal tidak valid." }
}

func parseDecimal(from text: String, locale: Locale = .current) throws -> Decimal {
    let nf = NumberFormatter()
    nf.locale = locale
    nf.numberStyle = .decimal
    nf.generatesDecimalNumbers = true
    
    var cleaned = text
        .replacingOccurrences(of: "Rp", with: "", options: .caseInsensitive)
        .replacingOccurrences(of: "IDR", with: "", options: .caseInsensitive)
        .replacingOccurrences(of: " ", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    
    if let n = nf.number(from: cleaned) as? NSDecimalNumber {
        return n.decimalValue
    }
    
    let lastDot = cleaned.lastIndex(of: ".")
    let lastComma = cleaned.lastIndex(of: ",")
    let decimalIsDot: Bool = {
        switch (lastDot, lastComma) {
        case let (d?, c?):
            return d > c
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            return true
        }
    }()
    
    if decimalIsDot {
        cleaned = cleaned.replacingOccurrences(of: ",", with: "")
    } else {
        cleaned = cleaned.replacingOccurrences(of: ".", with: "")
        cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
    }
    
    cleaned = cleaned.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
    
    let posix = NumberFormatter()
    posix.locale = Locale(identifier: "en_US_POSIX")
    posix.numberStyle = .decimal
    posix.generatesDecimalNumbers = true
    
    if let n2 = posix.number(from: cleaned) as? NSDecimalNumber {
        return n2.decimalValue
    }
    
    throw ParseDecimalError.invalidNumber
}

func parseDecimalOrNil(_ text: String, locale: Locale = .current) -> Decimal? {
    try? parseDecimal(from: text, locale: locale)
}
