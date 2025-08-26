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

}
