//
//  UserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol HasUserDataStorage {
    var userDataStorage: UserDataStoraging { get set }
}

protocol UserDataStoraging: UserStoraging {
    var userCategoryData: UserCategoryData? { get set }
    var userPointData: UserPointData? { get set }
    var genericPointData: GenericPointData? { get set }
    var userRankData: UserRankData? { get set }
    var loginData: LoginUserData? { get set }
}

final class UserDataStorage: UserDataStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var transactionCache: [String: Any] = [:]
    private var inTransaction: Bool = false
    // Internal storage dictionary to store values, will be replaced with SwiftData/Realm later
    private var internalStore: [String: Any] = [:]
    
    // MARK: - Public Properties
    
    var userCategoryData: UserCategoryData? {
        get { inTransaction ? transactionCache["userCategoryData"] as? UserCategoryData : internalStore["userCategoryData"] as? UserCategoryData }
        set {
            if inTransaction {
                transactionCache["userCategoryData"] = newValue
            } else {
                internalStore["userCategoryData"] = newValue
            }
        }
    }
    
    var userPointData: UserPointData? {
        get { inTransaction ? transactionCache["userPointData"] as? UserPointData : internalStore["userPointData"] as? UserPointData }
        set {
            if inTransaction {
                transactionCache["userPointData"] = newValue
            } else {
                internalStore["userPointData"] = newValue
            }
        }
    }
    
    var genericPointData: GenericPointData? {
        get { inTransaction ? transactionCache["pointData"] as? GenericPointData : internalStore["pointData"] as? GenericPointData }
        set {
            if inTransaction {
                transactionCache["pointData"] = newValue
            } else {
                internalStore["pointData"] = newValue
            }
        }
    }
    
    var userRankData: UserRankData? {
        get { inTransaction ? transactionCache["userRankData"] as? UserRankData : internalStore["userRankData"] as? UserRankData }
        set {
            if inTransaction {
                transactionCache["userRankData"] = newValue
            } else {
                internalStore["userRankData"] = newValue
            }
        }
    }
    
    var loginData: LoginUserData? {
        get { inTransaction ? transactionCache["loginData"] as? LoginUserData : internalStore["loginData"] as? LoginUserData }
        set {
            if inTransaction {
                if newValue == nil {
                    transactionCache["loginData"] = NSNull()
                } else {
                    transactionCache["loginData"] = newValue
                }
            } else {
                if newValue == nil {
                    internalStore["loginData"] = NSNull()
                } else {
                    internalStore["loginData"] = newValue
                }
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
        
        for (key, value) in transactionCache {
            internalStore[key] = value
            logger.log(message: "New value for \(key): \(value)")
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
