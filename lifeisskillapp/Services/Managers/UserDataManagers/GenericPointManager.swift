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

public final class GenericPointManager: BaseClass, GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage & HasUserManager
    private var userDataStorage: UserDataStoraging
    private var logger: LoggerServicing
    private var userDataAPIService: UserDataAPIServicing
    
    // MARK: - Public Properties
    weak var delegate: GenericPointManagerFlowDelegate?
    
    var data: GenericPointData? {
        get {
            userDataStorage.genericPointData
        }
        set {
            userDataStorage.genericPointData = newValue
        }
    }
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
    }
    
    // MARK: - Public Interface
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user points")
        do {
            let response = try await userDataAPIService.getPoints(baseURL: APIUrl.baseURL, userToken: token)
            userDataStorage.beginTransaction()
            data = response.data
            userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load points",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> GenericPoint? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [GenericPoint] {
        data?.data ?? []
    }
}
