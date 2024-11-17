//
//  TokenResponse.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation

struct TokenResponse: Codable {
  let accessToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}
