//
//  APIError.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

enum APIError: Error {
    case invalidURL
    case decodingFailed
    case requestFailed
    case unknown
    case httpError
    case apiFailed
}
