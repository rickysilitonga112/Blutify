//
//  AppPreference.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

public final class AppPreference: ObservableObject {
    static let shared = AppPreference()
    
    public var apiKey: String {
        if let basePath = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.apiKey] as? String {
            return basePath
        } else {
            return "empty_api_key"
        }
    }
    
    public var baseUrl: String {
        if let basePath = Bundle.main.infoDictionary?[BFConstants.InfoPlistKey.baseUrl] as? String {
            return basePath
        } else {
            return "empty_base_url"
        }
    }
}
