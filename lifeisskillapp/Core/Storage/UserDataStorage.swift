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
}

final class UserDataStorage: UserDataStoraging {
    private var transactionCache: [String: Any] = [:]
    private var inTransaction: Bool = false
    
    typealias Dependencies = HasLoggerServicing
    private var dependencies: Dependencies
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
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

    // Internal storage dictionary to store values
    private var internalStore: [String: Any] = [:]
    
    // MARK: - Transaction Methods
    func beginTransaction() {
        inTransaction = true
        transactionCache = [:]
        dependencies.logger.log(message: "Transaction started.")
    }
    
    func commitTransaction() {
        guard inTransaction else { return }
        
        for (key, value) in transactionCache {
            internalStore[key] = value
            dependencies.logger.log(message: "New value for \(key): \(value)")
        }
        
        inTransaction = false
        transactionCache = [:]
        dependencies.logger.log(message: "Transaction finished.")
    }
    
    func rollbackTransaction() {
        inTransaction = false
        transactionCache = [:]
        dependencies.logger.log(message: "Transaction rolled back.")
    }
}
