//
//  RankingRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmRankingRepository {
    var realmRankingRepository: any RealmRankingRepositoring { get set }
}

protocol RealmRankingRepositoring: RealmRepositoring where Entity == RealmRanking {}

public final class RealmRankingRepository: RealmRankingRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmRanking
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
