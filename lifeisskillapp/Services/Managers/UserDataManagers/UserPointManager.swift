//
//  UserPointManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserPointManagerFlowDelegate: NSObject {
    func onUserPointsUpdated()
}

protocol HasUserPointManager {
    var userPointManager: UserPointManaging { get }
}

protocol UserPointManaging {
    var delegate: UserPointManagerFlowDelegate? { get set }
    var userPointData: UserPointData? { get set }
    func loadUserPoints() async throws
    func getAllPoints() -> [UserPoint]
    func getPoints(byCategory category: String) -> [UserPoint]
}

public final class UserPointManager: UserPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage
    private var dependencies: Dependencies
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Public Properties
    weak var delegate: UserPointManagerFlowDelegate?
    
    var userPointData: UserPointData? {
        get {
            return dependencies.userDataStorage.userPointData
        }
        set {
            dependencies.userDataStorage.userPointData = newValue
        }
    }
    
    // MARK: - Public Interface
    func loadUserPoints() async throws {
        dependencies.logger.log(message: "Loading user points")
        do {
            let response = try await dependencies.userDataAPI.getUserPoints(baseURL: APIUrl.baseURL)
            dependencies.userDataStorage.beginTransaction()
            userPointData = response.data
            dependencies.userDataStorage.commitTransaction()
            delegate?.onUserPointsUpdated()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user points",
                logger: dependencies.logger
            )
        }
    }
    
    func getAllPoints() -> [UserPoint] {
        return userPointData?.data ?? []
    }
    
    func getPoints(byCategory category: String) -> [UserPoint] {
        return userPointData?.data.filter { $0.pointCategory.contains(category) } ?? []
    }
}
