//
//  BFService.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation

final class BFService {
  static let shared = BFService()
  
  private init() {}
  
  func request<T: Decodable>(
    _ endpoint: BFEndpoint,
    expecting: T.Type,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    guard let url = endpoint.url else {
      completion(.failure(NetworkError.invalidURL))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.allHTTPHeaderFields = endpoint.headers
    if let body = endpoint.body {
      request.httpBody = body
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else {
        completion(.failure(NetworkError.noData))
        return
      }
      
      do {
        let decodedObject = try JSONDecoder().decode(T.self, from: data)
        completion(.success(decodedObject))
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }
}

enum NetworkError: Error {
  case invalidURL
  case noData
  case decodingFailed
}
