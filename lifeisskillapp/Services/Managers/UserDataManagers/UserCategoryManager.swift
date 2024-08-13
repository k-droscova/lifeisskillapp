//
//  UserCategoryManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation
import Combine

protocol HasUserCategoryManager {
    var userCategoryManager: any UserCategoryManaging { get }
}

protocol UserCategoryManaging: UserDataManaging where DataType == UserCategory, DataContainer == UserCategoryData {
    func getMainCategory() -> UserCategory?
    var selectedCategory: UserCategory? { get set }
    var selectedCategoryPublisher: AnyPublisher<UserCategory?, Never> { get }
}

public final class UserCategoryManager: BaseClass, UserCategoryManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private let userDataAPIService: UserDataAPIServicing
    private var selectedCategorySubject = CurrentValueSubject<UserCategory?, Never>(nil)
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserDataManagerFlowDelegate?
    
    var data: UserCategoryData? {
        get {
            storage.userCategoryData
        }
        set {
            storage.userCategoryData = newValue
        }
    }
    
    var token: String? {
        get { userManager.token }
    }
    
    @Published var selectedCategory: UserCategory? {
        didSet {
            publishSelectedCategory()
        }
    }
    
    var selectedCategoryPublisher: AnyPublisher<UserCategory?, Never> {
        selectedCategorySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.userDataAPIService = dependencies.userDataAPI
        
        super.init()
        self.load()
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user categories")
        do {
            let response = try await userDataAPIService.getUserCategory(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
            selectedCategory = data?.main
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
            }
        }
        catch {
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
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .categories)
            self?.selectedCategory = self?.data?.main
        }
    }
    
    private func publishSelectedCategory() {
        DispatchQueue.main.async {
            self.selectedCategorySubject.send(self.selectedCategory)
        }
    }
}
