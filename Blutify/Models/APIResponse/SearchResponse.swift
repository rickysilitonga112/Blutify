//
//  SearchResponse.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation

struct SearchResponse: Codable {
  let tracks: Tracks

  struct Tracks: Codable {
    let items: [Track]
  }
}
