//
//  UserPointManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class UserPointManagerMock: UserPointManaging {
    var networkMonitor: NetworkMonitoring = NetworkMonitorMock()
    var scanningDelegate: ScanPointFlowDelegate?
    
    // MARK: - Mock Data and State Tracking
    
    var points: [UserPoint] = []
    var totalPoints: Int = 0
    var errorToThrow: Error?
    var scannedPointToHandle: ScannedPoint?
    var handleScannedPointCalled = false
    var handleAllStoredScannedPointsCalled = false
    var loadFromRepositoryCalled = false
    var fetchWithTokenCalled = false
    var getAllCalled = false
    var getByIdCalled = false
    var checkSumCalled = false
    var onLogoutCalled = false
    
    // Simulate network status (offline/online)
    var isOnline = true
    var isValid = true
    
    // Token simulation
    var token: String? = "mock-token"

    // MARK: - Mock Methods for UserPointManaging

    func loadFromRepository() async {
        loadFromRepositoryCalled = true
    }
    
    func fetch(withToken token: String) async throws {
        fetchWithTokenCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func getAll() -> [UserPoint] {
        getAllCalled = true
        return points
    }
    
    func getById(id: String) -> UserPoint? {
        getByIdCalled = true
        return points.first { $0.id == id }
    }
    
    func getPoints(byCategory categoryId: String) -> [UserPoint] {
        return points.filter { $0.pointCategory.contains(categoryId) }
    }
    
    func getTotalPoints(byCategory categoryId: String) -> Int {
        return getPoints(byCategory: categoryId)
            .filter { $0.doesPointCount }
            .reduce(0) { $0 + $1.pointValue }
    }
    
    func handleScannedPoint(_ point: ScannedPoint) async throws {
        handleScannedPointCalled = true
        scannedPointToHandle = point
        
        // Simulate error throwing if set
        if let error = errorToThrow {
            throw error
        }
        
        // Simulate delegate callback and validity checking
        if !isValid {
            scanningDelegate?.onScanPointInvalidPoint()
            return
        }
        
        // Call success depending on online status
        if isOnline {
            scanningDelegate?.onScanPointProcessSuccessOnline(point.codeSource)
        } else {
            scanningDelegate?.onScanPointProcessSuccessOffline(point.codeSource)
        }
    }
    
    func handleAllStoredScannedPoints() async throws {
        handleAllStoredScannedPointsCalled = true
        if let error = errorToThrow {
            throw error
        }
        // Simulate handling all stored scanned points
    }
    
    func checkSum() -> String? {
        checkSumCalled = true
        return "mocked-checksum"
    }
    
    func onLogout() {
        onLogoutCalled = true
        points.removeAll()
    }

    // MARK: - UserDataManaging Required Methods

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
