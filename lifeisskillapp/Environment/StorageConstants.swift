//
//  StorageConstants.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.08.2024.
//

import Foundation

struct KeychainConstants {
    static let usernameKey = (Bundle.main.infoDictionary?["KEYCHAIN_USERNAME_KEY"] as? String) ?? "default.username"
    static let passwordKey = (Bundle.main.infoDictionary?["KEYCHAIN_PASSWORD_KEY"] as? String) ?? "default.password"
}

struct RealmConstants {
    static let storageFile = (Bundle.main.infoDictionary?["REALM_FILE"] as? String) ?? "default.realm"
}
