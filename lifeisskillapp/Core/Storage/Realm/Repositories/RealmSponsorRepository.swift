//
//  RealmSponsorRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmSponsorRepository {
    var realmSponsorRepository: any RealmSponsorRepositoring { get set }
}

protocol RealmSponsorRepositoring: RealmRepositoring where Entity == RealmSponsorData {}

class RealmSponsorRepository: BaseClass, RealmSponsorRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmSponsorData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
