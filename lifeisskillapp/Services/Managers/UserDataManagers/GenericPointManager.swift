//
//  GenericPointDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation

protocol GenericPointManagerFlowDelegate: UserDataManagerFlowDelegate {
    
}

protocol HasGenericPointManager {
    var genericPointManager: any GenericPointManaging { get }
}

protocol GenericPointManaging: UserDataManaging where DataType == GenericPoint, DataContainer == GenericPointData {
    var delegate: GenericPointManagerFlowDelegate? { get set}
}

public final class GenericPointManager: GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage
    private var dependencies: Dependencies
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Public Properties
    weak var delegate: GenericPointManagerFlowDelegate?
    
    var data: GenericPointData? {
        get {
            return dependencies.userDataStorage.genericPointData
        }
        set {
            dependencies.userDataStorage.genericPointData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch() async throws {
        dependencies.logger.log(message: "Loading user points")
        do {
            let response = try await dependencies.userDataAPI.getPoints(baseURL: APIUrl.baseURL)
            dependencies.userDataStorage.beginTransaction()
            data = response.data
            dependencies.userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load points",
                logger: dependencies.logger
            )
        }
    }
    
    func getById(id: String) -> GenericPoint? {
        return data?.data.first { $0.id == id }
    }
    
    func getAll() -> [GenericPoint] {
        return data?.data ?? []
    }
    
}
