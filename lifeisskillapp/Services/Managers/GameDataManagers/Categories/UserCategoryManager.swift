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

final class UserCategoryManager: BaseClass, UserCategoryManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userDataAPIService: UserDataAPIServicing
    private var selectedCategorySubject = CurrentValueSubject<UserCategory?, Never>(nil)
    private var _data: UserCategoryData?
    
    internal let networkMonitor: NetworkMonitoring

    // MARK: - Public Properties
    
    var token: String? { storage.token }
    @Published var selectedCategory: UserCategory? {
        didSet {
            if oldValue?.id != selectedCategory?.id {
                publishSelectedCategory()
            }
        }
    }
    
    var selectedCategoryPublisher: AnyPublisher<UserCategory?, Never> {
        selectedCategorySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.loadFromRepository(for: .categories)
                self?._data = try await self?.storage.userCategoryData()
                self?.selectedCategory = try? await self?.storage.userCategoryData()?.main
            } catch {
                self?.logger.log(message: "Unable to load categories from storage")
            }
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Fetching user categories")
        let response = try await userDataAPIService.userCategories(userToken: token)
        try await storage.saveUserCategoryData(response.data)
        _data = response.data
        selectedCategory = _data?.main
    }
    
    func getById(id: String) -> UserCategory? {
        _data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserCategory] {
        _data?.data ?? []
    }
    
    func getMainCategory() -> UserCategory? {
        _data?.main
    }
    
    func onLogout() {
        _data = nil
    }
    
    func checkSum() -> String? {
        nil
    }
    
    // MARK: - Private Helpers
    
    private func publishSelectedCategory() {
        DispatchQueue.main.async {
            self.selectedCategorySubject.send(self.selectedCategory)
        }
    }
}
