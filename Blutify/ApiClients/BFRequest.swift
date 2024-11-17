//
//  SpotifyApi.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

final class BFRequest {
  static let shared = BFRequest()

  private let clientId = AppPreference.shared.clientId
  private let clientSecret = AppPreference.shared.clientSecret
  private let baseUrl = AppPreference.shared.baseUrl
  private let baseAuthUrl = AppPreference.shared.baseAuthUrl
  private var accessToken: String?

  private init() {}

  func authenticate(completion: @escaping (Bool) -> Void) {
    let credentials = "\(clientId):\(clientSecret)"
    let encodedCredentials = Data(credentials.utf8).base64EncodedString()

    let authEndpoint = BFEndpoint(
      baseURL: baseAuthUrl,
      path: "/api/token",
      method: .POST,
      headers: [
        "Authorization": "Basic \(encodedCredentials)",
        "Content-Type": "application/x-www-form-urlencoded"
      ],
      body: "grant_type=client_credentials".data(using: .utf8)
    )

    BFService.shared.request(authEndpoint, expecting: TokenResponse.self) { result in
      switch result {
      case .success(let tokenResponse):
        self.accessToken = tokenResponse.accessToken
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }

  func searchMusic(query: String, completion: @escaping ([Track]) -> Void) {
    guard let token = accessToken else {
      completion([])
      return
    }

    let endpoint = BFEndpoint(
      baseURL: baseUrl,
      path: "/search?q=\(query)&type=track",
      method: .GET,
      headers: [
        "Authorization": "Bearer \(token)"
      ],
      body: nil
    )


    BFService.shared.request(endpoint, expecting: SearchResponse.self) { result in
      switch result {
      case .success(let response):
        completion(response.tracks.items)
      case .failure:
        completion([])
      }
    }
  }

  func fetchRecommendations(completion: @escaping ([Track]) -> Void) {
    guard let token = accessToken else {
      completion([])
      return
    }

    let seedGenres = "pop"
    
    let endpoint = BFEndpoint(
      baseURL: baseUrl,
      path: "/recommendations?seed_genres=\(seedGenres)",
      method: .GET,
      headers: [
        "Authorization": "Bearer \(token)"
      ],
      body: nil
    )


    BFService.shared.request(endpoint, expecting: RecommendationsResponse.self) { result in
      switch result {
      case .success(let response):
        completion(response.tracks)
      case .failure:
        completion([])
      }
    }
  }
}
