//
//  GameDataManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
import Combine
@testable import lifeisskillapp

final class GameDataManagerMock: GameDataManaging {
    
    // MARK: - Delegate and Publishers
    weak var delegate: GameDataManagerFlowDelegate?
    private let isVirtualAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    var isVirtualAvailablePublisher: AnyPublisher<Bool, Never> {
        return isVirtualAvailableSubject.eraseToAnyPublisher()
    }

    // MARK: - Mock Data and State Tracking
    var errorToThrow: Error?
    var isVirtualAvailable: Bool = false {
        didSet {
            isVirtualAvailableSubject.send(isVirtualAvailable)
        }
    }
    
    // Flags to track method calls
    var reloadAfterRegistrationCalled = false
    var loadDataCalled = false
    var loadDataArgument: DataType? = nil
    var onPointScannedCalled = false
    var processVirtualCalled = false
    var performOnlineLoginCalled = false
    var performOfflineLoginCalled = false
    var scannedPointArgument: ScannedPoint?
    var virtualLocationArgument: UserLocation?

    // MARK: - GameDataManaging Mock Methods

    func reloadAfterRegistration() async throws {
        reloadAfterRegistrationCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func loadData(for dataType: DataType) async {
        loadDataCalled = true
        loadDataArgument = dataType
        // Optionally check or store the dataType
        if let error = errorToThrow {
            delegate?.onError(error)
        }
    }
    
    func onPointScanned(_ point: ScannedPoint) async {
        onPointScannedCalled = true
        scannedPointArgument = point
        if let error = errorToThrow {
            delegate?.onError(error)
        }
    }
    
    func processVirtual(location: UserLocation?) async {
        processVirtualCalled = true
        virtualLocationArgument = location
        if let error = errorToThrow {
            delegate?.onError(error)
        }
    }
    
    func performOnlineLogin() async throws {
        performOnlineLoginCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func performOfflineLogin() async throws {
        performOfflineLoginCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
}
