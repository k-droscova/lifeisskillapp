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
    var token: String? { get set }
    var credentials: LoginCredentials? { get set }
    var location: CLLocation? { get set }
    var checkSumData: CheckSumData? { get set }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    private var transactionCache: [String: Any] = [:]
    private var inTransaction: Bool = false
    
    typealias Dependencies = HasLoggerServicing
    private var logger: LoggerServicing
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
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
    
    var location: CLLocation? {
        get { inTransaction ? transactionCache["location"] as? CLLocation : UserDefaults.standard.location }
        set {
            if inTransaction {
                transactionCache["location"] = newValue
            } else {
                UserDefaults.standard.set(newValue, forKey: "location")
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
    
    var token: String? {
        get { inTransaction ? transactionCache["token"] as? String : UserDefaults.standard.string(forKey: "token") }
        set {
            if inTransaction {
                transactionCache["token"] = newValue
            } else {
                UserDefaults.standard.set(newValue, forKey: "token")
            }
        }
    }
    
    var credentials: LoginCredentials? {
        get {
            if inTransaction {
                return transactionCache["credentials"] as? LoginCredentials
            }
            guard let data = UserDefaults.standard.data(forKey: "credentials"),
                  let credentials = try? JSONDecoder().decode(LoginCredentials.self, from: data) else {
                return nil
            }
            return credentials
        }
        set {
            if inTransaction {
                transactionCache["credentials"] = newValue
            } else {
                if let newValue = newValue {
                    let data = try? JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: "credentials")
                } else {
                    UserDefaults.standard.removeObject(forKey: "credentials")
                }
            }
        }
    }
    
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
        if let token = transactionCache["token"] as? String {
            UserDefaults.standard.set(token, forKey: "token")
            logger.log(message: "New value for token: \(token)")
            
        }
        if let credentials = transactionCache["credentials"] as? LoginCredentials {
            if let data = try? JSONEncoder().encode(credentials) {
                UserDefaults.standard.set(data, forKey: "credentials")
                logger.log(message: "New credentials saved")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "credentials")
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
