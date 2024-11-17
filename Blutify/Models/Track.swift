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
    let artists: [Artist]
    let previewURL: URL?

    struct Artist: Codable {
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case previewURL = "preview_url"
    }
}
