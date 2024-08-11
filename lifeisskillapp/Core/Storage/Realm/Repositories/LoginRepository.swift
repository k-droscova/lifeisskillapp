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

public class RealmLoginRepository: BaseClass, RealmLoginRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmLoginDetails
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
