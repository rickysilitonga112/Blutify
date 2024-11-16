//
//  AuthManager.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var isUserSignIn: Bool {
        return true
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpireDate: Date? {
        return nil
    }
    
    private var isShouldRefreshToken: Bool {
        return false
    }
}
