//
//  StorageConstants.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.08.2024.
//

import Foundation

struct KeychainConstants {
    static let usernameKey = (Bundle.main.bundleIdentifier ?? "eu.cz.lifeisskill.app") + "username"
    static let passwordKey = (Bundle.main.bundleIdentifier ?? "eu.cz.lifeisskill.app") + "password"
}

struct RealmConstants {
    static let storageFile = (Bundle.main.bundleIdentifier ?? "eu.cz.lifeisskill.app") + ".realm"
}
