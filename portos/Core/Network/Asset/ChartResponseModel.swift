//
//  ChartResponseModel.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import Foundation

struct ChartAPIResponse: Decodable {
    let data: ChartPayload
    let message: String
    let status: Int
    let success: Bool
}
struct ChartPayload: Decodable {
    let symbol: String
    let type: String
    let range: String
    let points: [ChartPoint]
}

struct ChartPoint: Decodable {
    let date: String
    let close: Double
}

// Decoder tanggal "yyyy-MM-dd"
enum Decoders {
    static let yyyyMMdd: JSONDecoder = {
        let d = JSONDecoder()
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale   = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        d.dateDecodingStrategy = .formatted(f)
        return d
    }()
}
