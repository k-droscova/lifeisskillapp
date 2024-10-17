//
//  UserCategoryManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
import Combine
@testable import lifeisskillapp

final class UserCategoryManagerMock: UserCategoryManaging {
    
    // MARK: - Network Monitoring
    var networkMonitor: NetworkMonitoring = NetworkMonitorMock()
    
    // MARK: - Mock Data and State Tracking
    var categories: [UserCategory] = []
    var errorToThrow: Error?
    var selectedCategory: UserCategory? {
        didSet {
            selectedCategorySubject.send(selectedCategory)
        }
    }
    private let selectedCategorySubject = CurrentValueSubject<UserCategory?, Never>(nil)
    
    var selectedCategoryPublisher: AnyPublisher<UserCategory?, Never> {
        return selectedCategorySubject.eraseToAnyPublisher()
    }

    // Flags to track method calls
    var loadFromRepositoryCalled = false
    var fetchWithTokenCalled = false
    var getAllCalled = false
    var getByIdCalled = false
    var checkSumCalled = false
    var onLogoutCalled = false
    var getMainCategoryCalled = false
    
    // Simulate network status (offline/online)
    var isOnline = true
    
    // Token simulation
    var token: String? = "mock-token"
    
    // MARK: - UserCategoryManaging Specific Methods

    func getMainCategory() -> UserCategory? {
        getMainCategoryCalled = true
        // Return the first category as the main category for mock purposes
        return categories.first
    }

    // MARK: - UserDataManaging Required Methods

    func loadFromRepository() async {
        loadFromRepositoryCalled = true
        // Simulate loading categories from offline storage
    }
    
    func fetch(withToken token: String) async throws {
        fetchWithTokenCalled = true
        // Simulate fetching categories with a token from an API
        if let error = errorToThrow {
            throw error
        }
    }
    
    func getAll() -> [UserCategory] {
        getAllCalled = true
        return categories
    }
    
    func getById(id: String) -> UserCategory? {
        getByIdCalled = true
        return categories.first { $0.id == id }
    }
    
    func checkSum() -> String? {
        checkSumCalled = true
        return "mocked-checksum"
    }
    
    func onLogout() {
        onLogoutCalled = true
        categories.removeAll()
        selectedCategory = nil
    }

    func loadData() async throws {
        if let errorToThrow {
            throw errorToThrow
        } else if isOnline {
            try await fetch()
        } else {
            await loadFromRepository()
        }
    }
    
    func fetch() async throws {
        if let errorToThrow {
            throw errorToThrow
        } else if let token {
            try await fetch(withToken: token)
        }
    }
}
