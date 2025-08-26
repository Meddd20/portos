//
//  ExchangeRateResponse.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//
import Foundation

struct ExchangeRateResponse: Decodable {
    let success: Bool
    let message: String
    let data: Decimal
    let status: Int
}
