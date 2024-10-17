//
//  FlowDelegates.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
import UIKit
@testable import lifeisskillapp

final class ScanPointFlowDelegateMock: NSObject, ScanPointFlowDelegate {
    
    var onScanPointInvalidPointCalled = false
    var onScanPointNoLocationCalled = false
    var onScanPointProcessSuccessOnlineCalled = false
    var onScanPointProcessSuccessOfflineCalled = false
    var onScanPointOnlineProcessErrorCalled = false
    var onScanPointOfflineProcessErrorCalled = false
    
    var sourceArgument: CodeSource?

    func onScanPointInvalidPoint() {
        onScanPointInvalidPointCalled = true
    }

    func onScanPointNoLocation() {
        onScanPointNoLocationCalled = true
    }

    func onScanPointProcessSuccessOnline(_ source: CodeSource) {
        onScanPointProcessSuccessOnlineCalled = true
        sourceArgument = source
    }

    func onScanPointProcessSuccessOffline(_ source: CodeSource) {
        onScanPointProcessSuccessOfflineCalled = true
        sourceArgument = source
    }

    func onScanPointOnlineProcessError(_ source: CodeSource) {
        onScanPointOnlineProcessErrorCalled = true
        sourceArgument = source
    }

    func onScanPointOfflineProcessError() {
        onScanPointOfflineProcessErrorCalled = true
    }
}

final class SettingsBarFlowDelegateMock: NSObject, SettingsBarFlowDelegate {
    
    // Flags to track method calls
    var logoutPressedWhileOfflineCalled = false
    var onboardingPressedCalled = false
    var profilePressedCalled = false
    
    var userManager: UserManagerMock?
    var shouldLogout: Bool = true
    
    // MARK: - SettingsBarFlowDelegate Methods
    
    func logoutPressedWhileOffline() {
        logoutPressedWhileOfflineCalled = true
        if shouldLogout {
            userManager?.logout()
        }
    }
    
    func onboardingPressed() {
        onboardingPressedCalled = true
    }
    
    func profilePressed() {
        profilePressedCalled = true
    }
}

final class ProfileFlowDelegateMock: NSObject, ProfileFlowDelegate {
    
    // Flags to track method calls
    var generateQRCalled = false
    var generateQRDidFailCalled = false
    var returnToHomeScreenCalled = false
    var startRegistrationCalled = false
    var loadUserDataDidFailCalled = false
    var emailRequestNotSentCalled = false
    var emailRequestDidSucceedCalled = false
    var emailRequestDidFailCalled = false
    
    // Arguments to capture the passed data
    var qrImage: UIImage?

    // MARK: - ProfileFlowDelegate Methods
    
    func generateQR(content: UIImage) {
        generateQRCalled = true
        qrImage = content
    }
    
    func generateQRDidFail() {
        generateQRDidFailCalled = true
    }
    
    func returnToHomeScreen() {
        returnToHomeScreenCalled = true
    }
    
    func startRegistration() {
        startRegistrationCalled = true
    }
    
    func loadUserDataDidFail() {
        loadUserDataDidFailCalled = true
    }
    
    func emailRequestNotSent() {
        emailRequestNotSentCalled = true
    }
    
    func emailRequestDidSucceed() {
        emailRequestDidSucceedCalled = true
    }
    
    func emailRequestDidFail() {
        emailRequestDidFailCalled = true
    }
}
