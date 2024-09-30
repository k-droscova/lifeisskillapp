//
//  RealmStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import RealmSwift
@testable import lifeisskillapp

final class RealmStorageMock: RealmStoraging {
    
    private var inMemoryRealm: Realm?
    
    // can simulate specific configurations (e.g., schema versions).
    var configurations: Realm.Configuration = Realm.Configuration(inMemoryIdentifier: "RealmStorageMock")
    
    init() {
        setupInMemoryRealm()
    }
    
    // This function returns the in-memory Realm instance for testing.
    func getRealm() -> Realm? {
        inMemoryRealm
    }
    
    // For teardown after each test
    func clearRealm() {
        guard let realm = inMemoryRealm else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    // Set up an in-memory Realm instance with the provided configuration
    private func setupInMemoryRealm() {
        do {
            inMemoryRealm = try Realm(configuration: configurations)
        } catch {
            print("Failed to initialize in-memory Realm: \(error)")
            inMemoryRealm = nil
        }
    }
}
