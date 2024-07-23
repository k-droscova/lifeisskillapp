//
//  UserDefaultsStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.07.2024.
//

import Foundation
import CoreLocation

protocol HasUserDefaultsStorage {
    var userDefaultsStorage: UserDefaultsStoraging { get set }
}

protocol UserDefaultsStoraging : UserStoraging {
    var appId: String? { get set }
    var location: UserLocation? { get set }
    var checkSumData: CheckSumData? { get set }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var transactionCache: [String: Any] = [:]
    private var inTransaction: Bool = false
    
    // MARK: - Public Properties
    
    var checkSumData: CheckSumData? {
        get { inTransaction ? transactionCache["checkSumData"] as? CheckSumData : UserDefaults.standard.checkSumData }
        set {
            if inTransaction {
                transactionCache["checkSumData"] = newValue
            } else {
                UserDefaults.standard.set(newValue, forKey: "checkSumData")
            }
        }
    }
    
    var location: UserLocation? {
        get {
            if inTransaction {
                return transactionCache["location"] as? UserLocation
            }
            guard let data = UserDefaults.standard.data(forKey: "location"),
                  let location = try? JSONDecoder().decode(UserLocation.self, from: data) else {
                return nil
            }
            return location
        }
        set {
            if inTransaction {
                transactionCache["location"] = newValue
            } else {
                if let newValue = newValue {
                    let data = try? JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: "location")
                } else {
                    UserDefaults.standard.removeObject(forKey: "location")
                }
            }
        }
    }
    
    var appId: String? {
        get { inTransaction ? transactionCache["appId"] as? String : UserDefaults.standard.string(forKey: "appId") }
        set {
            if inTransaction {
                transactionCache["appId"] = newValue
            } else {
                UserDefaults.standard.set(newValue, forKey: "appId")
            }
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    // MARK: - Public Interface
    
    func beginTransaction() {
        inTransaction = true
        transactionCache = [:]
        logger.log(message: "Transaction started.")
    }
    
    func commitTransaction() {
        guard inTransaction else { return }
        
        if let appId = transactionCache["appId"] as? String {
            UserDefaults.standard.set(appId, forKey: "appId")
            logger.log(message: "New value for appId: \(appId)")
        }
        if let location = transactionCache["location"] as? CLLocation {
            if let data = location.toData() {
                UserDefaults.standard.set(data, forKey: "location")
                logger.log(message: "New location saved")
            }
        }
        if let checkSumData = transactionCache["checkSumData"] as? CheckSumData {
            UserDefaults.standard.checkSumData = checkSumData
            logger.log(message: "New CheckSumData saved")
        } else {
            UserDefaults.standard.removeObject(forKey: "checkSumData")
        }
        
        inTransaction = false
        transactionCache = [:]
        logger.log(message: "Transaction finished.")
    }
    
    func rollbackTransaction() {
        inTransaction = false
        transactionCache = [:]
        logger.log(message: "Transaction rolled back.")
    }
}
