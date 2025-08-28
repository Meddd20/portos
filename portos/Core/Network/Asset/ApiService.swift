//
//  ApiService.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import Foundation

struct ApiService {
    static func fetchAssets(completion: @escaping (Result<APIResponse, APIError>) -> Void) {
        guard let url = URL(string: "https://getallassets-qtszyblonq-uc.a.run.app/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                let assets = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(assets))
            } catch {
                print("lala")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    static func getAssetById(id: String,
                        completion: @escaping (Result<APIResponseGetByID, APIError>) -> Void) {
        
        var comps = URLComponents(string: "https://getassetbyid-qtszyblonq-uc.a.run.app/")
        
        comps?.queryItems = [URLQueryItem(name: "id", value: id)]
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
                let response = try JSONDecoder().decode(APIResponseGetByID.self, from: data)
                completion(.success(response))
            } catch {
                print("lala")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    static func getChartDataTimeseries(type: String,
                                       symbol: String,
                                       range: String,
                                       completion: @escaping (Result<ChartAPIResponse, APIError>) -> Void) {
        let code = type.uppercased()
        
        guard code == "STOCK" || code == "CRYPTO" else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard range == "3m" || range == "1y" || range == "5y" else {
            completion(.failure(.invalidURL))
            return
        }
        
        var comps = URLComponents(string: "http://34.171.18.14:3000/historical/price")
        comps?.queryItems = [URLQueryItem(name: "type", value: code),
                             URLQueryItem(name: "symbol", value: symbol),
                             URLQueryItem(name: "range", value: range)]
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
                let response = try JSONDecoder().decode(ChartAPIResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("hihihi")
                print(error.localizedDescription)
                
                print("Decoding failed with error: \(error.localizedDescription)")
                print("Request URL:", url.absoluteString)
                print("Headers:", req.allHTTPHeaderFields ?? [:])
                if let body = req.httpBody {
                    print("Body:", String(data: body, encoding: .utf8) ?? "nil")
                }
                
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}
