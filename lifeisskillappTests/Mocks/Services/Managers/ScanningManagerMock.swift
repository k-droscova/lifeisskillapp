//
//  ScanningManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class ScanningManagerMock: ScanningManaging {
    
    var errorToThrow: Error? = nil
    var isValid: Bool = true
    
    var handleScannedPointOnlineCalled = false
    var handleScannedPointOfflineCalled = false
    var sendAllStoredScannedPointsCalled = false
    var checkValidityCalled = false
    
    var scannedPointArgument: ScannedPoint?
    
    func handleScannedPointOnline(_ point: ScannedPoint) async throws {
        handleScannedPointOnlineCalled = true
        scannedPointArgument = point
        guard let error = errorToThrow else {
            return
        }
        throw error
    }
    
    func handleScannedPointOffline(_ point: ScannedPoint) async throws {
        handleScannedPointOfflineCalled = true
        scannedPointArgument = point
        guard let error = errorToThrow else {
            return
        }
        throw error
    }
    
    func sendAllStoredScannedPoints() async throws {
        sendAllStoredScannedPointsCalled = true
        guard let error = errorToThrow else {
            return
        }
        throw error
    }
    
    func checkValidity(_ point: ScannedPoint) -> Bool {
        checkValidityCalled = true
        return isValid
    }
}
