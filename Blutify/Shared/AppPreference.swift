//
//  AppPreference.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

public final class AppPreference: ObservableObject {
  static let shared = AppPreference()

  public var baseUrl: String {
    if let baseUrl = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.baseUrl] as? String {
      return baseUrl
    } else {
      return "empty_base_url"
    }
  }

  public var baseAuthUrl: String {
    if let baseAuthUrl = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.baseAuthUrl] as? String {
      return baseAuthUrl
    } else {
      return "empty_base_auth_url"
    }
  }

  public var clientId: String {
    if let basePath = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.clientId] as? String {
      return basePath
    } else {
      return "empty_client_id"
    }
  }

  public var clientSecret: String {
    if let basePath = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.clientSecret] as? String {
      return basePath
    } else {
      return "empty_client_secret"
    }
  }
}
