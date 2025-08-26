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

}
