//
//  UserCategoryManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserCategoryManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserCategoryManager {
    var userCategoryManager: any UserCategoryManaging { get }
}

protocol UserCategoryManaging: UserDataManaging where DataType == UserCategory, DataContainer == UserCategoryData {
    var delegate: UserCategoryManagerFlowDelegate? { get set }
    func getMainCategory() -> UserCategory?
    var selectedCategory: UserCategory? { get set }
    var selectedCategoryStream: AsyncStream<UserCategory?> { get }
}

public final class UserCategoryManager: BaseClass, UserCategoryManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private var userDataStorage: UserDataStoraging
    private let logger: LoggerServicing
    private let dataManager: UserLoginDataManaging
    private let userDataAPIService: UserDataAPIServicing
    private var selectedCategoryContinuation: AsyncStream<UserCategory?>.Continuation?
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserCategoryManagerFlowDelegate?
    
    var data: UserCategoryData? {
        get {
            userDataStorage.userCategoryData
        }
        set {
            userDataStorage.userCategoryData = newValue
        }
    }
    
    var token: String? {
        get { dataManager.token }
    }
    
    @Published var selectedCategory: UserCategory? {
        didSet {
            triggerAsyncStream()
        }
    }
    
    var selectedCategoryStream: AsyncStream<UserCategory?> {
        AsyncStream { continuation in
            self.selectedCategoryContinuation = continuation
            continuation.yield(self.selectedCategory)
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.dataManager = dependencies.userLoginManager
        self.userDataAPIService = dependencies.userDataAPI
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user categories")
        do {
            let response = try await userDataAPIService.getUserCategory(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
            selectedCategory = data?.main
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user categories",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserCategory? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserCategory] {
        data?.data ?? []
    }
    
    func getMainCategory() -> UserCategory? {
        data?.main
    }
    
    // MARK: - Private Helpers
    
    private func triggerAsyncStream() {
        DispatchQueue.main.async {
            self.selectedCategoryContinuation?.yield(self.selectedCategory)
        }
    }
}
