//
//  KeychainAccessible.swift
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/07/01.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import Security
import Foundation

protocol KeychainAccessible {
    static func set(object: Data?, on key: String, securtyClass: KeychainSecurityClass) throws
    static func get(from key: String, securityClass: KeychainSecurityClass) throws -> Data?
}

// MARK: Convenience

extension KeychainAccessible {
    static func set(object: Data?, on key: String) throws {
        try set(object: object, on: key, securtyClass: .genericPassword)
    }
    
    static func get(from key: String) throws -> Data? {
        return try get(from: key, securityClass: .genericPassword)
    }
}

extension KeychainAccessible {
    static func setString(_ string: String, on key: String) throws {
        try set(object: string.data(using: .utf8), on: key)
    }
    
    static func getString(from key: String) throws -> String? {
        do {
            if let stringData = try get(from: key) {
                return String(bytes: stringData, encoding: .utf8)
            }
            
            return nil
        } catch {
            throw error
        }
    }
}
