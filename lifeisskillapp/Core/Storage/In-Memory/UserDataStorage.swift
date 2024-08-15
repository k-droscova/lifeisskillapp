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

protocol UserDataStoraging {
    var userCategoryData: UserCategoryData? { get set }
    var userPointData: UserPointData? { get set }
    var genericPointData: GenericPointData? { get set }
    var userRankData: UserRankData? { get set }
    var checkSumData: CheckSumData? { get set }
}

final class UserDataStorage: UserDataStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    /*
     Internal storage dictionary to store values, will be replaced with SwiftData/Realm later
     Note: [String: Any] cannot store nil directly, hence we store NSNull instead when newValue is nil, and return nil when stored value is NSNull
     */
    private var internalStore: [String: Any] = [:]
    
    // MARK: - Public Properties
    
    var userCategoryData: UserCategoryData? {
        get {
            if let data = internalStore["userCategoryData"] as? UserCategoryData {
                return data
            } else if internalStore["userCategoryData"] is NSNull {
                return nil
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                internalStore["userCategoryData"] = NSNull()
            } else {
                internalStore["userCategoryData"] = newValue
            }
        }
    }
    
    var userPointData: UserPointData? {
        get {
            if let data = internalStore["userPointData"] as? UserPointData {
                return data
            } else if internalStore["userPointData"] is NSNull {
                return nil
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                internalStore["userPointData"] = NSNull()
            } else {
                internalStore["userPointData"] = newValue
            }
        }
    }
    
    var genericPointData: GenericPointData? {
        get {
            if let data = internalStore["pointData"] as? GenericPointData {
                return data
            } else if internalStore["pointData"] is NSNull {
                return nil
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                internalStore["pointData"] = NSNull()
            } else {
                internalStore["pointData"] = newValue
            }
        }
    }
    
    var userRankData: UserRankData? {
        get {
            if let data = internalStore["userRankData"] as? UserRankData {
                return data
            } else if internalStore["userRankData"] is NSNull {
                return nil
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                internalStore["userRankData"] = NSNull()
            } else {
                internalStore["userRankData"] = newValue
            }
        }
    }
    
    var checkSumData: CheckSumData? {
        get {
            if let data = internalStore["checkSumData"] as? CheckSumData {
                return data
            } else if internalStore["checkSumData"] is NSNull {
                return nil
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                internalStore["checkSumData"] = NSNull()
            } else {
                internalStore["checkSumData"] = newValue
            }
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
}
