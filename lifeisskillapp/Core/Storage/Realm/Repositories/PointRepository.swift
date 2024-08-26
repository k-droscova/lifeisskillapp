//
//  PointRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmGenericPointRepository {
    var realmPointRepository: any RealmGenericPointRepositoring { get set }
}

protocol RealmGenericPointRepositoring: RealmRepositoring where Entity == RealmGenericPointData {}

public class RealmGenericPointRepository: BaseClass, RealmGenericPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmGenericPointData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
