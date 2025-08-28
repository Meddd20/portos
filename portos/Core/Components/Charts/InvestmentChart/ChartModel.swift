//
//  ChartModel.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import Foundation

struct DataPoint: Identifiable, Hashable, Codable {
    let id = UUID()
    let date: Date
    let value: Double
    
    enum CodingKeys: String, CodingKey { case date, value = "close" }
}
