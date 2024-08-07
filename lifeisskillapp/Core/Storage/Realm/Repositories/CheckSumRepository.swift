//
//  CheckSumRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmCheckSumRepository {
    var realmCheckSumRepository: any RealmCheckSumRepositoring { get set }
}

protocol RealmCheckSumRepositoring: RealmRepositoring where Entity == RealmCheckSumData {}

public class RealmCheckSumRepository: BaseClass, RealmCheckSumRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmCheckSumData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
