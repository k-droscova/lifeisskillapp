//
//  GenericPointDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation
import Combine

protocol GenericPointManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasGenericPointManager {
    var genericPointManager: any GenericPointManaging { get }
}

protocol GenericPointManaging: UserDataManaging where DataType == GenericPoint, DataContainer == GenericPointData {
    var delegate: GenericPointManagerFlowDelegate? { get set}
}

public final class GenericPointManager: BaseClass, GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let dataManager: UserLoginDataManaging
    private let userDataAPIService: UserDataAPIServicing
    private var cancellables = Set<AnyCancellable>()
    private var checkSum: String?
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: GenericPointManagerFlowDelegate?
    
    var data: GenericPointData? {
        get {
            storage.genericPointData
        }
        set {
            storage.genericPointData = newValue
        }
    }
    
    var token: String? {
        get { dataManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.dataManager = dependencies.userLoginManager
        self.userDataAPIService = dependencies.userDataAPI
        
        super.init()
        self.load()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user points")
        do {
            let response = try await userDataAPIService.getPoints(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
            }
        }
        catch {
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
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .userPoints)
        }
    }
}
