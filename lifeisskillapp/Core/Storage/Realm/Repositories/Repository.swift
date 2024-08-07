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
    func delete(_ entity: Entity) throws
    func getAll() -> Results<Entity>?
    func getById(_ id: String) -> Entity?
}

extension RealmRepositoring where Self: HasRealmStoraging & HasLoggers {
    func save(_ entity: Entity) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger)
        }
        try realm.write {
            realm.add(entity, update: .modified)
        }
    }
    
    func delete(_ entity: Entity) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: self.logger)
            
        }
        try realm.write {
            realm.delete(entity)
        }
    }
    
    func getAll() -> Results<Entity>? {
        guard let realm = realmStorage.getRealm() else { return nil }
        return realm.objects(Entity.self)
    }
    
    func getById(_ id: String) -> Entity? {
        guard let realm = realmStorage.getRealm() else { return nil }
        return realm.object(ofType: Entity.self, forPrimaryKey: id)
    }
}
