//
//  Track.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

struct Track: Codable {
    let id: String
    let name: String
    let artist: String
    let previewURL: URL?

    private struct Artist: Codable {
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case previewURL = "preview_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        // Decode nested artists array and extract the first artist's name
        let artists = try container.decode([Artist].self, forKey: .artists)
        artist = artists.first?.name ?? "Unknown Artist"

        previewURL = try? container.decode(URL.self, forKey: .previewURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        // Encode the artist back as an array of artists
        let artists = [Artist(name: artist)]
        try container.encode(artists, forKey: .artists)

        try container.encode(previewURL, forKey: .previewURL)
    }
}

