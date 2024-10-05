//
//  ScannedPointRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmScannedPointRepository {
    var realmScannedPointRepository: any RealmScannedPointRepositoring { get set }
}

protocol RealmScannedPointRepositoring: RealmRepositoring where Entity == RealmScannedPoint {
    func getScannedPoints() throws -> [ScannedPoint]
}

class RealmScannedPointRepository: BaseClass, RealmScannedPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmScannedPoint
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func getScannedPoints() throws -> [ScannedPoint] {
        let realmPoints = try getAll()
        return realmPoints.map { $0.scannedPoint() }
    }
}
