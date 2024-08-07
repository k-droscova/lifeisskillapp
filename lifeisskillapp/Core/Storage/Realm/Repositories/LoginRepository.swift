//
//  LoginRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmLoginRepository {
    var realmLoginRepository: any RealmLoginRepositoring { get set }
}

protocol RealmLoginRepositoring: RealmRepositoring where Entity == RealmLoginDetails {}

public final class RealmLoginRepository: RealmLoginRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmLoginDetails
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    // MARK: - Public Properties
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
