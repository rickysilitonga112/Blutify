//
//  Track.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

struct Track {
  let id: String
  let name: String
  let artist: String
  let previewURL: URL?

  init?(json: [String: Any]) {
    guard
      let id = json["id"] as? String,
      let name = json["name"] as? String,
      let artistArray = json["artists"] as? [[String: Any]],
      let artist = artistArray.first?["name"] as? String
    else { return nil }

    self.id = id
    self.name = name
    self.artist = artist
    self.previewURL = URL(string: json["preview_url"] as? String ?? "")
  }
}
