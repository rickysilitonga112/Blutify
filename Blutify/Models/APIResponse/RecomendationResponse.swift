//
//  RecomendationResponse.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation

struct RecommendationsResponse: Decodable {
  let tracks: [Track]
}
