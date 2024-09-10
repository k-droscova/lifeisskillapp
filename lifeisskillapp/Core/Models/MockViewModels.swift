//
//  MockViewModels.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.09.2024.
//

import Foundation

final class MockLocationStatusBarViewModel: BaseClass, LocationStatusBarViewModeling {
    var userLocation: UserLocation? = UserLocation(latitude: 51.5074, longitude: -0.1278, altitude: 0, accuracy: 0, timestamp: Date()) // Mock London location
    var appVersion: String = "1.0.0"
    var isOnline: Bool = true
    var isGpsOk: Bool = true

    init(dependencies: HasLoggers & HasLocationManager & HasNetworkMonitor) {
        // Mock implementation
    }
}

final class MockSettingsBarViewModel: BaseClass, SettingsBarViewModeling {
    typealias locationStatusBarVM = MockLocationStatusBarViewModel

    var locationVM: locationStatusBarVM = MockLocationStatusBarViewModel(dependencies: appDependencies)
    var isLoggedIn: Bool = true
    var showProfileMenuOption: Bool = true

    func logoutPressed() {
        // Mock implementation
    }

    func profilePressed() {
        // Mock implementation
    }

    func onboardingPressed() {
        // Mock implementation
    }

    func hideProfileNavigationOption() {
        showProfileMenuOption = false
    }
    
    init(dependencies: any HasLoggers & HasLocationManager & HasUserManager & HasNetworkMonitor, delegate: (any SettingsBarFlowDelegate)?) {
        // Mock
    }
}

final class MockProfileViewModel: BaseClass, ProfileViewModeling {
    typealias settingBarVM = MockSettingsBarViewModel

    var settingsViewModel: settingBarVM = MockSettingsBarViewModel(dependencies: appDependencies, delegate: nil)
    var isLoading: Bool = false
    
    var requiresToCompleteRegistration: Bool = false
    var requiresParentEmailActivation: Bool = true
    var guardianEmailValidationState: ValidationState = GuardianEmailValidationState.base(.initial)
    var isSendActivationButtonEnabled: Bool = true
    
    var username: String = "JohnDoe"
    var userGender: UserGender = .male
    var email: String = "john.doe@example.com"
    var mainCategory: String = "Gaming"
    var name: String = "John"
    var phoneNumber: String = "+1234567890"
    var postalCode: String = "12345"
    var birthday: String = "01-01-2000"
    var age: Int = 12
    var isMinor: Bool = true
    var parentName: String = "Jane Doe"
    var parentEmail: String = "jane.doe@example.com"
    var parentPhone: String = "+0987654321"
    var parentRelation: String = "Mother"
    var parentActivationEmail: String = "kcsnkcjsn"

    func inviteFriend() {
        // Mock implementation
    }
    
    func startRegistration() {
        // Mock implementation
    }
    
    func navigateBack() {
        // Mock implementation
    }
    
    func sendParentActivationEmail() {
        print("Mock sending parent activation email to \(parentEmail)")
    }
}
