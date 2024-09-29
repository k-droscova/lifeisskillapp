//
//  LoginRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmLoginRepository {
    var realmLoginRepository: any RealmLoginRepositoring { get set }
}

protocol RealmLoginRepositoring: RealmRepositoring where Entity == RealmLoginDetails {
    func getSavedLoginDetails() throws -> RealmLoginDetails?
    func getLoggedInUser() throws -> RealmLoginDetails?
    func saveLoginUser(_ user: LoggedInUser) throws
    func markUserAsLoggedOut() throws
    func markUserAsLoggedIn() throws
}

public class RealmLoginRepository: BaseClass, RealmLoginRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmLoginDetails
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    let logger: LoggerServicing
    var realmStorage: RealmStoraging
    var token: String? { getLoggedInUserToken() }
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func getSavedLoginDetails() throws -> RealmLoginDetails? {
        return try getAll().first
    }
    
    func getLoggedInUser() throws -> RealmLoginDetails? {
        return try getAll().first(where: { $0.isLoggedIn })
    }
    
    func saveLoginUser(_ user: LoggedInUser) throws {
        let loginDetails = RealmLoginDetails(from: user)
        try save(loginDetails)
    }
    
    func markUserAsLoggedOut() throws {
        guard let loggedInUser = try getSavedLoginDetails() else {
            throw BaseError(
                context: .database,
                message: "No user is currently logged in.",
                logger: logger
            )
        }
        
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Failed to get Realm instance",
                logger: logger
            )
        }
        
        try realm.write {
            loggedInUser.isLoggedIn = false
            realm.add(loggedInUser, update: .modified)
        }
    }
    
    func markUserAsLoggedIn() throws {
        guard let loggedInUser = try getSavedLoginDetails() else {
            throw BaseError(
                context: .database,
                message: "No user is currently logged in.",
                logger: logger
            )
        }
        
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Failed to get Realm instance",
                logger: logger
            )
        }
        
        try realm.write {
            loggedInUser.isLoggedIn = true
            realm.add(loggedInUser, update: .modified)
        }
    }
    
    // MARK: - Private Helpers
    
    private func getLoggedInUserToken() -> String? {
        do {
            guard let loggedInUser = try getSavedLoginDetails(), loggedInUser.isLoggedIn else { return nil }
            return loggedInUser.token
        } catch {
            // SHOULD NEVER GET TO THIS, accessing token should only happen after login
            logger.log(message: "No logged in user token available")
            return nil
        }
    }
}
