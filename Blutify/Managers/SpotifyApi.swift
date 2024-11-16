//
//  SpotifyApi.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

class SpotifyAPI {

  static let shared = SpotifyAPI()

  private let clientId = AppPreference.shared.clientId
  private let clientSecret = AppPreference.shared.clientSecret
  private var accessToken: String?

  func authenticate(completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://accounts.spotify.com/api/token")!
    let credentials = "\(clientId):\(clientSecret)"
    let encodedCredentials = Data(credentials.utf8).base64EncodedString()

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
    request.httpBody = "grant_type=client_credentials".data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data, error == nil else {
        completion(false)
        return
      }

      if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let token = json["access_token"] as? String {
        self.accessToken = token
        completion(true)
      } else {
        completion(false)
      }
    }.resume()
  }

  func searchMusic(query: String, completion: @escaping ([Track]) -> Void) {
    guard let token = accessToken else { return }
    let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=track"
    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, _, _ in
      guard let data = data else { return }
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let tracksData = json?["tracks"] as? [String: Any]
      let items = tracksData?["items"] as? [[String: Any]] ?? []

      let tracks = items.compactMap { Track(json: $0) }
      completion(tracks)
    }.resume()
  }

  func fetchRecommendations(completion: @escaping ([Track]) -> Void) {
      guard let token = accessToken else {
          completion([])
          return
      }

      let seedArtists = "4NHQUGzhtTLFvgF5SZesLK"
      let seedGenres = "pop"
      let seedTracks = "0c6xIDDpzE81m2q797ordA"
      let urlString = "https://api.spotify.com/v1/recommendations?seed_artists=\(seedArtists)&seed_genres=\(seedGenres)&seed_tracks=\(seedTracks)"
      guard let url = URL(string: urlString) else {
          completion([])
          return
      }

      var request = URLRequest(url: url)
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

      URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
              print("Error fetching recommendations: \(error.localizedDescription)")
              completion([])
              return
          }

          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let tracksData = json["tracks"] as? [[String: Any]] else {
              print("Invalid response or data.")
              completion([])
              return
          }

          let tracks = tracksData.compactMap { Track(json: $0) }
          completion(tracks)
      }.resume()
  }


}
