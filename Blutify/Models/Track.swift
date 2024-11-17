//
//  Track.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

struct Track: Codable {
  let id: String?
  let name: String?
  let artists: [Artist]?
  let album: Album?
  let previewURL: URL?

  struct Artist: Codable {
    let name: String?
  }

  struct Image: Codable {
    let url: String?
    let width: Int?
    let height: Int?
  }

  struct Album: Codable {
    let name: String?
    let images: [Image]?
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case artists
    case album
    case previewURL = "preview_url"
  }
}
