//
//  PointRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmPointRepository {
    var realmPointRepository: any RealmPointRepositoring { get set }
}

protocol RealmPointRepositoring: RealmRepositoring where Entity == RealmPoint {}

public final class RealmPointRepository: RealmPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmPoint
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
