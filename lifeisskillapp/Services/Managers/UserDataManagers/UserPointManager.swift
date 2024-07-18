//
//  UserPointManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserPointManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserPointManager {
    var userPointManager: any UserPointManaging { get }
}

protocol UserPointManaging: UserDataManaging where DataType == UserPoint, DataContainer == UserPointData {
    var delegate: UserPointManagerFlowDelegate? { get set }
    func getPoints(byCategory categoryId: String) -> [UserPoint]
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
    
    var data: UserPointData? {
        get {
            return dependencies.userDataStorage.userPointData
        }
        set {
            dependencies.userDataStorage.userPointData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch() async throws {
        dependencies.logger.log(message: "Loading user points")
        do {
            let response = try await dependencies.userDataAPI.getUserPoints(baseURL: APIUrl.baseURL)
            dependencies.userDataStorage.beginTransaction()
            data = response.data
            dependencies.userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user points",
                logger: dependencies.logger
            )
        }
    }
    
    func getById(id: String) -> UserPoint? {
        return data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserPoint] {
        return data?.data ?? []
    }
    
    func getPoints(byCategory categoryId: String) -> [UserPoint] {
        return data?.data.filter { $0.pointCategory.contains(categoryId) } ?? []
    }
}
