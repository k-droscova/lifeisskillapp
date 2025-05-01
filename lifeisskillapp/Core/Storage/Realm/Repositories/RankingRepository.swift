//
//  RankingRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmUserRankRepository {
    var realmUserRankRepository: any RealmUserRankRepositoring { get set }
}

protocol RealmUserRankRepositoring: RealmRepositoring where Entity == RealmUserRankData {}

class RealmUserRankRepository: BaseClass, RealmUserRankRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmUserRankData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
