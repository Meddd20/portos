//
//  EXchangeRateService.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import Foundation

struct ExchangeRateService {
    static func getRate(currency: String,
                        completion: @escaping (Result<ExchangeRateResponse, APIError>) -> Void) {
        let code = currency.uppercased()
        
        guard code == "USD" || code == "IDR" else {
            completion(.failure(.invalidURL))
            return
        }
        
        var comps = URLComponents(string: "https://getexchangerate-qtszyblonq-uc.a.run.app/")
        comps?.queryItems = [URLQueryItem(name: "currency", value: code)]
        guard let url = comps?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code:", httpResponse.statusCode)
            }

            if let _ = error {
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("lala")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    static func getConversionRate(from fromCurrency: Currency, to toCurrency: Currency, completion: @escaping (Result<Double, APIError>) -> Void) {
        // If currencies are the same, return 1.0
        if fromCurrency == toCurrency {
            completion(.success(1.0))
            return
        }
        
        // Get the rate from the API
        getRate(currency: fromCurrency.rawValue) { result in
            switch result {
            case .success(let response):
                let rate = Double(truncating: response.data as NSNumber)
                
                // Calculate conversion rate
                let conversionRate: Double
                if fromCurrency == .usd && toCurrency == .idr {
                    // USD to IDR: multiply by rate (e.g., 1 USD * 16586 = 16586 IDR)
                    conversionRate = rate
                } else if fromCurrency == .idr && toCurrency == .usd {
                    // IDR to USD: divide by rate (e.g., 16586 IDR / 16586 = 1 USD)
                    conversionRate = rate  // We'll divide by this rate in the ViewModel
                } else {
                    // Fallback for unexpected combinations
                    conversionRate = 1.0
                }
                
                completion(.success(conversionRate))
                
            case .failure(let error):
                // If API fails, use fallback rate
                let fallbackRate: Double
                if fromCurrency == .usd && toCurrency == .idr {
                    fallbackRate = 16586.0 // Fallback USD to IDR rate
                } else if fromCurrency == .idr && toCurrency == .usd {
                    fallbackRate = 16586.0 // Fallback IDR to USD rate (we'll divide by this)
                } else {
                    fallbackRate = 1.0
                }
                
                print("API failed, using fallback rate: \(fallbackRate)")
                completion(.success(fallbackRate))
            }
        }
    }
}
