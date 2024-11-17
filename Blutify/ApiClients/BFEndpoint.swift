//
//  BFEndpoint.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation

struct BFEndpoint {
  enum HTTPMethod: String {
    case GET
    case POST
  }

  let baseURL: String
  let path: String
  let method: HTTPMethod
  let headers: [String: String]?
  let body: Data?

  var url: URL? {
    URL(string: baseURL + path)
  }
}
