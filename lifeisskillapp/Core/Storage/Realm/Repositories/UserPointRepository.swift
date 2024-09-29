//
//  PointScanRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmUserPointRepository {
    var realmUserPointRepository: any RealmUserPointRepositoring { get set }
}

protocol RealmUserPointRepositoring: RealmRepositoring where Entity == RealmUserPointData {}

public class RealmUserPointRepository: BaseClass, RealmUserPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmUserPointData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
