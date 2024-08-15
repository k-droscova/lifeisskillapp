//
//  GenericPointDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation
import Combine

protocol HasGenericPointManager {
    var genericPointManager: any GenericPointManaging { get }
}

protocol GenericPointManaging: UserDataManaging where DataType == GenericPoint, DataContainer == GenericPointData {
}

public final class GenericPointManager: BaseClass, GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private let userDataAPIService: UserDataAPIServicing
    private var cancellables = Set<AnyCancellable>()
    private var checkSum: String?
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserDataManagerFlowDelegate?
    
    var data: GenericPointData? {
        get {
            storage.genericPointData
        }
        set {
            storage.genericPointData = newValue
        }
    }
    
    var token: String? {
        get { userManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.userDataAPIService = dependencies.userDataAPI
        
        super.init()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .userPoints)
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user points")
        do {
            let response = try await userDataAPIService.getPoints(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
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
}
