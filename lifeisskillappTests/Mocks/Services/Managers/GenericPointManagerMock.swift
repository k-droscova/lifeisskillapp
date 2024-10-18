//
//  GenericPointManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
import Combine
@testable import lifeisskillapp

final class GenericPointManagerMock: GenericPointManaging {
    
    // MARK: - Network Monitoring
    var networkMonitor: NetworkMonitoring = NetworkMonitorMock()
    
    // MARK: - Mock Data and State Tracking
    var points: [GenericPoint] = []
    var totalPoints: Int = 0
    var errorToThrow: Error?
    var checkSumReturnValue: String? = "mock-checksum"
    
    var closestVirtualPoint: GenericPoint?
    private let closestVirtualPointSubject = CurrentValueSubject<GenericPoint?, Never>(nil)
    var closestVirtualPointPublisher: AnyPublisher<GenericPoint?, Never> {
        return closestVirtualPointSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Flags for Tracking Method Calls
    var loadFromRepositoryCalled = false
    var fetchWithTokenCalled = false
    var getAllCalled = false
    var getByIdCalled = false
    var checkSumCalled = false
    var onLogoutCalled = false
    var sponsorImageCalled = false
    
    // Simulate network status (offline/online)
    var isOnline = true
    
    // Token simulation
    var token: String? = "mock-token"

    // MARK: - Mock Methods for GenericPointManaging
    
    func sponsorImage(for sponsorId: String, width: Int, height: Int) async throws -> Data? {
        sponsorImageCalled = true
        // Simulate error or success
        if let error = errorToThrow {
            throw error
        }
        // Simulate returning image data or nil
        return Data()
    }

    // MARK: - UserDataManaging Required Methods

    func loadFromRepository() async {
        loadFromRepositoryCalled = true
        // Simulate loading data from repository (offline mode)
    }
    
    func fetch(withToken token: String) async throws {
        fetchWithTokenCalled = true
        // Simulate fetching data with a token (online mode)
        if let error = errorToThrow {
            throw error
        }
    }
    
    func getAll() -> [GenericPoint] {
        getAllCalled = true
        return points
    }
    
    func getById(id: String) -> GenericPoint? {
        getByIdCalled = true
        return points.first { $0.id == id }
    }
    
    func checkSum() -> String? {
        checkSumCalled = true
        return checkSumReturnValue
    }
    
    func onLogout() {
        onLogoutCalled = true
        points.removeAll()
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
