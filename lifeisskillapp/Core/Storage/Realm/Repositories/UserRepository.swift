//
//  UserRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmUserRepository {
    var realmUserRepository: any RealmUserRepositoring { get set }
}

protocol RealmUserRepositoring: RealmRepositoring where Entity == RealmUser {}

public final class RealmUserRepository: RealmUserRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmUser
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
