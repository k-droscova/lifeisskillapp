//
//  Repository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol RealmRepositoring {
    associatedtype Entity: Object
    func save(_ entity: Entity) throws
    func save(_ entities: [Entity]) throws
    func delete(_ entity: Entity) throws
    func delete(_ entities: [Entity]) throws
    func deleteAll() throws
    func getAll() throws -> [Entity]
    func getById(_ id: String) throws -> Entity?
}

extension RealmRepositoring where Self: HasRealmStoraging & HasLoggers {
    
    func save(_ entity: Entity) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        try realm.write {
            realm.add(entity, update: .modified)
        }
    }
    
    func save(_ entities: [Entity]) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        try realm.write {
            realm.add(entities, update: .modified)
        }
    }
    
    func delete(_ entity: Entity) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        try realm.write {
            realm.delete(entity)
        }
    }
    
    func delete(_ entities: [Entity]) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        try realm.write {
            realm.delete(entities)
        }
    }
    
    func deleteAll() throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        try realm.write {
            let allEntities = realm.objects(Entity.self)
            realm.delete(allEntities)
        }
    }
    
    func getAll() throws -> [Entity] {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        return Array(realm.objects(Entity.self))
    }
    
    func getById(_ id: String) throws -> Entity? {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger
            )
        }
        return realm.object(ofType: Entity.self, forPrimaryKey: id)
    }
}
