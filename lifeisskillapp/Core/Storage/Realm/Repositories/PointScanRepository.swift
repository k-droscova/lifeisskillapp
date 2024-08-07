//
//  PointScanRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmPointScanRepository {
    var realmPointScanRepository: any RealmPointScanRepositoring { get set }
}

protocol RealmPointScanRepositoring: RealmRepositoring where Entity == RealmPointScan {}

public class RealmPointScanRepository: BaseClass, RealmPointScanRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmPointScan
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
