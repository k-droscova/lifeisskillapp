//
//  ProfileViewModelMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class ProfileViewModelTests: XCTestCase {
    
    private var viewModel: ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>!
    private var mockLocationManager: LocationManagerMock!
    private var mockLogger: LoggingServiceMock!
    private var mockNetworkMonitor: NetworkMonitorMock!
    private var mockUserManager: UserManagerMock!
    private var mockUserCategoryManager: UserCategoryManagerMock!
    private var mockDelegate: ProfileFlowDelegateMock!
    
    struct MockDependencies: HasLoggers & HasNetworkMonitor & SettingsBarViewModel.Dependencies & HasUserCategoryManager {
        let locationManager: LocationManaging
        let logger: LoggerServicing
        let networkMonitor: NetworkMonitoring
        let userCategoryManager: any UserCategoryManaging
        let userManager: UserManaging
    }
    
    override func setUp() {
        super.setUp()
        
        // Initialize the mocks
        mockLogger = LoggingServiceMock()
        mockLocationManager = LocationManagerMock()
        mockNetworkMonitor = NetworkMonitorMock()
        mockUserManager = UserManagerMock()
        mockUserCategoryManager = UserCategoryManagerMock()
        mockDelegate = ProfileFlowDelegateMock()
        
        // Set the dependencies
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockLogger = nil
        mockNetworkMonitor = nil
        mockUserManager = nil
        mockUserCategoryManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testInitialLoadData() {
        // Arrange
        let mockUser = LoggedInUser.mock()
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock(id: "Main Category", name: "Main Category"), .mock(id: "Second Category"), .mock(id: "Third Category")]
        
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        
        // Assert
        XCTAssertEqual(viewModel.username, mockUser.nick)
        XCTAssertEqual(viewModel.email, mockUser.email)
        XCTAssertEqual(viewModel.mainCategory, "Main Category")
    }
    
    func testInviteFriendFetchesSignatureWhenOnline() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken"
        )
        mockUserManager.loggedInUser = mockUser
        mockUserManager.signatureReturnValue = "mocked-signature" // Mock the signature
        mockNetworkMonitor.mockOnlineStatus = true // Simulate online status
        
        let expectation = self.expectation(description: "Signature is fetched")
        
        // Act: Call inviteFriend(), which is async
        viewModel.inviteFriend()
        
        // Delay to allow async operation to complete and check signature
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Assert that the signature was fetched
            XCTAssertTrue(self.mockUserManager.signatureCalled, "Signature should be fetched when online.")
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation with a timeout
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testInviteFriendUsesTokenWhenOffline() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken" // Set the token that should be used when offline
        )
        mockUserManager.loggedInUser = mockUser
        mockUserManager.signatureReturnValue = nil // Signature should not be fetched when offline
        mockNetworkMonitor.mockOnlineStatus = false // Simulate offline status
        
        let expectation = self.expectation(description: "Token is used when offline")
        
        // Act: Call inviteFriend(), which is async
        viewModel.inviteFriend()
        
        // Delay to allow async operation to complete and check if the signature was not called
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Assert that the signature was NOT called
            XCTAssertFalse(self.mockUserManager.signatureCalled, "Signature should NOT be fetched when offline.")
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation with a timeout
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testInviteFriendGeneratesQRCodeCorrectly() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken"
        )
        mockUserManager.loggedInUser = mockUser
        mockUserManager.signatureReturnValue = "mocked-signature" // Mock the signature
        mockNetworkMonitor.mockOnlineStatus = true // Simulate online status
        
        let expectation = self.expectation(description: "QR code is generated")
        
        // Act: Call inviteFriend(), which is async
        viewModel.inviteFriend()
        
        // Delay to allow async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Assert that the QR code was generated
            XCTAssertTrue(self.mockDelegate.generateQRCalled, "QR code should be generated.")
            XCTAssertNotNil(self.mockDelegate.qrImage, "Generated QR image should not be nil.")
            
            // Optionally: Verify the content of the QR image (if you want to decode and validate the image)
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation with a timeout
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testInviteFriendGeneratesCorrectQRCodeImage() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken"
        )
        mockUserManager.loggedInUser = mockUser
        mockUserManager.signatureReturnValue = "mocked-signature" // Mock the signature
        mockNetworkMonitor.mockOnlineStatus = true // Simulate online status
        
        let expectation = self.expectation(description: "QR code image is generated")
        
        // Act: Call inviteFriend(), which is async
        viewModel.inviteFriend()
        
        // Delay to allow async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Assert that the QR image was generated
            XCTAssertNotNil(self.mockDelegate.qrImage, "Generated QR image should not be nil.")
            
            // Decode the QR image and check the contents
            if let qrImage = self.mockDelegate.qrImage {
                let decodedString = self.decodeQRCode(from: qrImage)
                let expectedQRString = "https://testweb.lifeisskill.cz/ref/task=%7Bref%7D&key=%7BHenry%7D&key1=%7BMTIzNDU%7D&key2=%7Bmocked-signature%7D&key3=%7Bfalse%7D&game=%7BLife%20is%20Skill%7D"
                XCTAssertEqual(decodedString, expectedQRString, "Decoded QR code should contain the expected string.")
            }
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation with a timeout
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSendParentActivationEmailSuccess() {
        // Arrange
        mockUserManager.requestParentEmailActivationLinkReturnValue = true
        viewModel.parentActivationEmail = "parent@example.com"
        
        let expectation = self.expectation(description: "Email request succeeded")
        
        // Act
        viewModel.sendParentActivationEmail()
        
        // Delay to allow async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            // Assert that the email request succeeded
            XCTAssertTrue(self.mockUserManager.requestParentEmailActivationLinkCalled, "requestParentEmailActivationLink should be called.")
            XCTAssertTrue(self.mockDelegate.emailRequestDidSucceedCalled, "emailRequestDidSucceed should be called.")
            expectation.fulfill()
        }

        // Wait for the expectation
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testRequiresToCompleteRegistration_WhenActivationStatusIsIncomplete() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken",
            activationStatus: .incomplete // Set activation status to incomplete
        )
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock()]
        // Act
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )

        // Assert
        XCTAssertTrue(viewModel.requiresToCompleteRegistration, "requiresToCompleteRegistration should be true when activation status is incomplete.")
        XCTAssertFalse(viewModel.requiresParentEmailActivation, "requiresParentEmailActivation should be false when activation status is incomplete.")
    }

    func testRequiresParentEmailActivation_WhenActivationStatusIsParentActivationRequired() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken",
            activationStatus: .parentActivationRequired // Set activation status to parentActivationRequired
        )
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock()]

        // Act
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        
        // Assert
        XCTAssertFalse(viewModel.requiresToCompleteRegistration, "requiresToCompleteRegistration should be false when activation status is parentActivationRequired.")
        XCTAssertTrue(viewModel.requiresParentEmailActivation, "requiresParentEmailActivation should be true when activation status is parentActivationRequired.")
    }

    func testRequiresToCompleteRegistration_WhenActivationStatusIsFullyActivated() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            nick: "Henry",
            token: "MockUserToken",
            activationStatus: .fullyActivated // Set activation status to fullyActivated
        )
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock()]

        // Act
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )

        // Assert
        XCTAssertFalse(viewModel.requiresToCompleteRegistration, "requiresToCompleteRegistration should be false when activation status is fullyActivated.")
        XCTAssertFalse(viewModel.requiresParentEmailActivation, "requiresParentEmailActivation should be false when activation status is fullyActivated.")
    }
    
    func testParentActivationEmailValidationLogic() {
        // Arrange
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            email: "user@example.com",
            nick: "Henry",
            token: "MockUserToken",
            activationStatus: .parentActivationRequired,
            emailParent: "parent@example.com"
        )
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock()]

        // Act
        let dependencies = MockDependencies(
            locationManager: mockLocationManager,
            logger: mockLogger,
            networkMonitor: mockNetworkMonitor,
            userCategoryManager: mockUserCategoryManager,
            userManager: mockUserManager
        )
        
        viewModel = ProfileViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        
        // Test 1: Initially, `parentActivationEmail` should match `emailParent`
        XCTAssertEqual(viewModel.parentActivationEmail, "parent@example.com", "Initial parentActivationEmail should match emailParent.")
        XCTAssertTrue(viewModel.isSendActivationButtonEnabled, "isSendActivationButtonEnabled should be true initially.")
        XCTAssertTrue(viewModel.guardianEmailValidationState.isValid, "Guardian email state should be valid initially.")

        // Test 2: Change parentActivationEmail to the user's email
        viewModel.parentActivationEmail = "user@example.com"
        XCTAssertFalse(viewModel.isSendActivationButtonEnabled, "isSendActivationButtonEnabled should be false when parentActivationEmail matches user's email.")
        XCTAssertFalse(viewModel.guardianEmailValidationState.isValid, "Guardian email state should be invalid when matching user's email.")

        // Test 3: Change parentActivationEmail to an empty string
        viewModel.parentActivationEmail = ""
        XCTAssertFalse(viewModel.isSendActivationButtonEnabled, "isSendActivationButtonEnabled should be false when parentActivationEmail is empty.")
        XCTAssertFalse(viewModel.guardianEmailValidationState.isValid, "Guardian email state should be invalid when it is empty.")

        // Test 4: Change parentActivationEmail to an invalid email format
        viewModel.parentActivationEmail = "invalidEmail"
        XCTAssertFalse(viewModel.isSendActivationButtonEnabled, "isSendActivationButtonEnabled should be false when parentActivationEmail is in an invalid format.")
        XCTAssertFalse(viewModel.guardianEmailValidationState.isValid, "Guardian email state should be invalid not in valid format.")

        // Test 5: Change parentActivationEmail to a valid, non-user email
        viewModel.parentActivationEmail = "newparent@example.com"
        XCTAssertTrue(viewModel.isSendActivationButtonEnabled, "isSendActivationButtonEnabled should be true when parentActivationEmail is valid and doesn't match user's email.")
        XCTAssertTrue(viewModel.guardianEmailValidationState.isValid, "Guardian email state should be valid when in valid format.")
    }
    
    func testStartRegistration() {
        // Act
        viewModel.startRegistration()

        // Assert
        XCTAssertTrue(mockDelegate.startRegistrationCalled, "startRegistration should trigger the delegate's startRegistration.")
    }
    
    func testNavigateBack() {
        // Act
        viewModel.navigateBack()

        // Assert
        XCTAssertTrue(mockDelegate.returnToHomeScreenCalled, "navigateBack should trigger the delegate's returnToHomeScreen.")
    }
    
    func testReloadDataAfterRegistration() {
        let mockUser = LoggedInUser.mock(
            userId: "12345",
            email: "user@example.com",
            nick: "new Nickname for User",
            token: "MockUserToken",
            activationStatus: .parentActivationRequired,
            emailParent: "parent@example.com"
        )
        mockUserManager.loggedInUser = mockUser
        mockUserCategoryManager.categories = [.mock()]
        let expectation = self.expectation(description: "Reload data called")
        
        // Act
        viewModel.reloadDataAfterRegistration()

        // Delay to allow async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            XCTAssertEqual(self?.viewModel.username, mockUser.nick)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}

extension ProfileViewModelTests {
    func decodeQRCode(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        if let features = detector?.features(in: ciImage), !features.isEmpty {
            if let qrFeature = features.first as? CIQRCodeFeature {
                return qrFeature.messageString
            }
        }
        
        return nil
    }
}
