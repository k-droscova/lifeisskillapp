//
//  UserRankManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class UserRankManagerMock: UserRankManaging {
    // MARK: - Network Monitoring
    var networkMonitor: NetworkMonitoring = NetworkMonitorMock()
    
    // MARK: - Mock Data and State Tracking
    var ranks: [UserRank] = []
    var errorToThrow: Error?
    var checkSumReturnValue: String? = "mock-checksum"
    
    // Flags to track method calls
    var loadFromRepositoryCalled = false
    var fetchWithTokenCalled = false
    var getAllCalled = false
    var getByIdCalled = false
    var checkSumCalled = false
    var onLogoutCalled = false
    
    // Simulate network status (offline/online)
    var isOnline = true
    
    // Token simulation
    var token: String? = "mock-token"

    // MARK: - UserRankManaging Specific Methods

    // MARK: - UserDataManaging Required Methods

    func loadFromRepository() async {
        loadFromRepositoryCalled = true
        // Simulate loading ranks from offline storage
    }
    
    func fetch(withToken token: String) async throws {
        fetchWithTokenCalled = true
        // Simulate fetching ranks with a token from an API
        if let error = errorToThrow {
            throw error
        }
    }
    
    func getAll() -> [UserRank] {
        getAllCalled = true
        return ranks
    }
    
    func getById(id: String) -> UserRank? {
        getByIdCalled = true
        return ranks.first { $0.id == id }
    }
    
    func checkSum() -> String? {
        checkSumCalled = true
        return checkSumReturnValue
    }
    
    func onLogout() {
        onLogoutCalled = true
        ranks.removeAll()
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
