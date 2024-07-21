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
}

final class UserDataStorage: UserDataStoraging {
    private var transactionCache: [String: Any] = [:]
    private var inTransaction: Bool = false
    
    typealias Dependencies = HasLoggerServicing
    private var logger: LoggerServicing
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    // MARK: - UserCategoryData Property
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
    
    // MARK: - UserPointData Property
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
    
    // MARK: - Generic PointData Property
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
    
    // MARK: - UserPointData Property
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
    
    // Internal storage dictionary to store values
    // MARK: - will be replaced with SwiftData/Realm later
    private var internalStore: [String: Any] = [:]
    
    // MARK: - Transaction Methods
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
