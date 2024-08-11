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
    func getLoggedInUser() throws -> RealmLoginDetails?
    func saveLoginUser(_ user: LoggedInUser) throws
    func markUserAsLoggedOut() throws
}

public class RealmLoginRepository: BaseClass, RealmLoginRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmLoginDetails
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func getLoggedInUser() throws -> RealmLoginDetails? {
        return try getAll().first(where: { $0.isLoggedIn })
    }
    
    func saveLoginUser(_ user: LoggedInUser) throws {
        let loginDetails = RealmLoginDetails(from: user)
        try save(loginDetails)
    }
    
    func markUserAsLoggedOut() throws {
        guard let loggedInUser = try getLoggedInUser() else {
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
}
