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

final class FullRegistrationFlowDelegateMock: NSObject, FullRegistrationFlowDelegate {
    var registrationDidSucceedAdultCalled = false
    var registrationDidSucceedMinorCalled = false
    var registrationDidFailCalled = false
    
    func registrationDidSucceedAdult() {
        registrationDidSucceedAdultCalled = true
    }
    
    func registrationDidSucceedMinor() {
        registrationDidSucceedMinorCalled = true
    }
    
    func registrationDidFail() {
        registrationDidFailCalled = true
    }
}

final class LoginFlowDelegateMock: NSObject, LoginFlowDelegate {
    
    var loginSuccessfulCalled = false
    var loginFailedCalled = false
    var promptToCompleteRegistrationCalled = false
    var promptParentToActivateAccountCalled = false
    var userNotActivatedCalled = false
    var offlineLoginFailedCalled = false
    var registerTappedCalled = false
    var forgotPasswordTappedCalled = false
    
    func loginSuccessful() {
        loginSuccessfulCalled = true
    }

    func loginFailed() {
        loginFailedCalled = true
    }

    func promptToCompleteRegistration() {
        promptToCompleteRegistrationCalled = true
    }

    func promptParentToActivateAccount() {
        promptParentToActivateAccountCalled = true
    }

    func userNotActivated() {
        userNotActivatedCalled = true
    }

    func offlineLoginFailed() {
        offlineLoginFailedCalled = true
    }

    func registerTapped() {
        registerTappedCalled = true
    }

    func forgotPasswordTapped() {
        forgotPasswordTappedCalled = true
    }
}

final class GameDataManagerFlowDelegateMock: NSObject, GameDataManagerFlowDelegate {

    // MARK: - Properties to track method calls
    var onErrorCalled = false
    var onInvalidTokenCalled = false
    var storedScannedPointsFailedToSendCalled = false

    // MARK: - Properties to store the arguments
    var errorArgument: Error?

    // MARK: - GameDataManagerFlowDelegate Conformance

    func onError(_ error: Error) {
        onErrorCalled = true
        errorArgument = error
    }

    func onInvalidToken() {
        onInvalidTokenCalled = true
    }

    func storedScannedPointsFailedToSend() {
        storedScannedPointsFailedToSendCalled = true
    }
}

final class UserManagerFlowDelegateMock: NSObject, UserManagerFlowDelegate {
    
    // MARK: - Flags for Method Calls
    var onLogoutCalled = false
    var onForceLogoutCalled = false
    
    // MARK: - UserManagerFlowDelegate Conformance
    
    func onLogout() {
        onLogoutCalled = true
    }
    
    func onForceLogout() {
        onForceLogoutCalled = true
    }
}

import Foundation
@testable import lifeisskillapp

final class HomeFlowDelegateMock: NSObject, HomeFlowDelegate {

    // MARK: - Scanning flow flags
    var loadFromQRCalled = false
    var dismissQRCalled = false
    var loadFromCameraCalled = false
    var dismissCameraCalled = false
    
    // MARK: - Message flow flags
    var featureUnavailableCalled = false
    var onFailureCalled = false
    
    // MARK: - Navigation flow flags
    var showOnboardingCalled = false
    
    // MARK: - Scan Point Flow flags
    var onScanPointInvalidPointCalled = false
    var onScanPointNoLocationCalled = false
    var onScanPointProcessSuccessOnlineCalled = false
    var onScanPointProcessSuccessOfflineCalled = false
    var onScanPointOnlineProcessErrorCalled = false
    var onScanPointOfflineProcessErrorCalled = false

    // MARK: - Captured values
    var capturedQRViewModel: QRViewModeling?
    var capturedOcrViewModel: OcrViewModeling?
    var capturedCodeSourceForFeatureUnavailable: CodeSource?
    var capturedCodeSourceForOnFailure: CodeSource?
    var capturedCodeSourceForScanPointSuccessOnline: CodeSource?
    var capturedCodeSourceForScanPointSuccessOffline: CodeSource?
    var capturedCodeSourceForScanPointErrorOnline: CodeSource?

    // MARK: - Scanning flow methods
    func loadFromQR(viewModel: QRViewModeling) {
        loadFromQRCalled = true
        capturedQRViewModel = viewModel
    }

    func dismissQR() {
        dismissQRCalled = true
    }

    func loadFromCamera(viewModel: OcrViewModeling) {
        loadFromCameraCalled = true
        capturedOcrViewModel = viewModel
    }

    func dismissCamera() {
        dismissCameraCalled = true
    }
    
    // MARK: - Message flow methods
    func featureUnavailable(source: CodeSource) {
        featureUnavailableCalled = true
        capturedCodeSourceForFeatureUnavailable = source
    }

    func onFailure(source: CodeSource) {
        onFailureCalled = true
        capturedCodeSourceForOnFailure = source
    }
    
    // MARK: - Navigation flow methods
    func showOnboarding() {
        showOnboardingCalled = true
    }
    
    // MARK: - Scan Point Flow Delegate methods
    
    func onScanPointInvalidPoint() {
        onScanPointInvalidPointCalled = true
    }
    
    func onScanPointNoLocation() {
        onScanPointNoLocationCalled = true
    }
    
    func onScanPointProcessSuccessOnline(_ source: CodeSource) {
        onScanPointProcessSuccessOnlineCalled = true
        capturedCodeSourceForScanPointSuccessOnline = source
    }
    
    func onScanPointProcessSuccessOffline(_ source: CodeSource) {
        onScanPointProcessSuccessOfflineCalled = true
        capturedCodeSourceForScanPointSuccessOffline = source
    }
    
    func onScanPointOnlineProcessError(_ source: CodeSource) {
        onScanPointOnlineProcessErrorCalled = true
        capturedCodeSourceForScanPointErrorOnline = source
    }
    
    func onScanPointOfflineProcessError() {
        onScanPointOfflineProcessErrorCalled = true
    }
}

final class PointsFlowDelegateMock: NSObject, PointsFlowDelegate {
    
    // MARK: - Flags to Track Method Calls
    var onErrorCalled = false
    var onNoDataAvailableCalled = false
    var selectCategoryPromptCalled = false
    
    // MARK: - Captured Values
    var capturedError: Error?

    // MARK: - Delegate Methods
    
    func onError(_ error: Error) {
        onErrorCalled = true
        capturedError = error
    }
    
    func onNoDataAvailable() {
        onNoDataAvailableCalled = true
    }
    
    func selectCategoryPrompt() {
        selectCategoryPromptCalled = true
    }
}

final class RankFlowDelegateMock: NSObject, RankFlowDelegate {
    
    // MARK: - Flags to Track Method Calls
    var onErrorCalled = false
    var onNoDataAvailableCalled = false
    var selectCategoryPromptCalled = false
    
    // MARK: - Captured Values
    var capturedError: Error?

    // MARK: - Delegate Methods
    
    func onError(_ error: Error) {
        onErrorCalled = true
        capturedError = error
    }
    
    func onNoDataAvailable() {
        onNoDataAvailableCalled = true
    }
    
    func selectCategoryPrompt() {
        selectCategoryPromptCalled = true
    }
}

final class RegistrationFlowDelegateMock: NSObject, RegistrationFlowDelegate {
    
    // MARK: - Flags to Track Method Calls
    var loadQRCalled = false
    var dismissQRCalled = false
    var showReferenceInstructionsCalled = false
    var scanningQRDidSucceedCalled = false
    var scanningQRDidFailCalled = false
    var registrationDidSucceedCalled = false
    var registrationDidFailCalled = false
    var openLinkCalled = false
    
    // MARK: - Captured Values
    var capturedViewModel: QRViewModeling?
    var capturedReferenceInfo: ReferenceInfo?
    var capturedLink: String?
    
    // MARK: - Delegate Methods
    
    func loadQR(viewModel: QRViewModeling) {
        loadQRCalled = true
        capturedViewModel = viewModel
    }
    
    func dismissQR() {
        dismissQRCalled = true
    }
    
    func showReferenceInstructions() {
        showReferenceInstructionsCalled = true
    }
    
    func scanningQRDidSucceed(_ reference: ReferenceInfo) {
        scanningQRDidSucceedCalled = true
        capturedReferenceInfo = reference
    }
    
    func scanningQRDidFail() {
        scanningQRDidFailCalled = true
    }
    
    func registrationDidSucceed() {
        registrationDidSucceedCalled = true
    }
    
    func registrationDidFail() {
        registrationDidFailCalled = true
    }
    
    func openLink(link: String) {
        openLinkCalled = true
        capturedLink = link
    }
}

final class ForgotPasswordFlowDelegateMock: NSObject, ForgotPasswordFlowDelegate {

    // Flags to track method calls
    var didRequestNewPinCalled = false
    var failedRequestNewPinCalled = false
    var didValidatePinCalled = false
    var failedValidatePinCalled = false
    var didRenewPasswordCalled = false
    var failedRenewPasswordCalled = false
    var timerRanOutCalled = false

    // Implement the protocol methods and set the corresponding flags

    func didRequestNewPin() {
        didRequestNewPinCalled = true
    }

    func failedRequestNewPin() {
        failedRequestNewPinCalled = true
    }

    func didValidatePin() {
        didValidatePinCalled = true
    }

    func failedValidatePin() {
        failedValidatePinCalled = true
    }

    func didRenewPassword() {
        didRenewPasswordCalled = true
    }

    func failedRenewPassword() {
        failedRenewPasswordCalled = true
    }

    func timerRanOut() {
        timerRanOutCalled = true
    }
}
