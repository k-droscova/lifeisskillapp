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
    func getScannedPoints() async throws -> [ScannedPoint]
}

public class RealmScannedPointRepository: BaseClass, RealmScannedPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmScannedPoint
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func getScannedPoints() async throws -> [ScannedPoint] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                guard let realm = realmStorage.getRealm() else {
                    throw BaseError(
                        context: .database,
                        message: "Realm is not initialized",
                        logger: self.logger
                    )
                }
                
                let realmPoints = realm.objects(RealmScannedPoint.self)
                let scannedPoints = realmPoints.map { $0.scannedPoint()}
                continuation.resume(returning: Array(scannedPoints))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
