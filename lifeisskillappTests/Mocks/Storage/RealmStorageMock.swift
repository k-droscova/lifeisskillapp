//
//  RealmStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import RealmSwift
@testable import lifeisskillapp
import Foundation

final class RealmStorageMock: RealmStoraging {
    
    private var inMemoryRealm: Realm?
    var shouldThrowError: Bool = false
    
    var configurations: Realm.Configuration {
        return Realm.Configuration(inMemoryIdentifier: "\(UUID().uuidString)")
    }
    
    init() {
        setupInMemoryRealm()
    }
    
    func getRealm() -> Realm? {
        return shouldThrowError ? nil : inMemoryRealm
    }
    
    func clearRealm() throws {
        guard let realm = inMemoryRealm else { return }
        try realm.write {
            realm.deleteAll()
        }
    }
    
    private func setupInMemoryRealm() {
        do {
            inMemoryRealm = try Realm(configuration: configurations)
        } catch {
            print("Failed to initialize in-memory Realm: \(error)")
            inMemoryRealm = nil
        }
    }
}
