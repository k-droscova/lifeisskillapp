//
//  SettingsBarViewModelMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import SwiftUI
@testable import lifeisskillapp

final class SettingsBarViewModelMock<locationVM: LocationStatusBarViewModeling>: BaseClass, SettingsBarViewModeling {
    
    // MARK: - Published Properties
    @Published var isOnline: Bool = false
    @Published var isGpsOk: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var showProfileMenuOption: Bool = true
    
    // MARK: - Properties
    var userLocation: UserLocation? = nil
    var appVersion: String = "DEBUG"
    var locationVM: locationVM

    // Delegate to track actions
    private weak var delegate: SettingsBarFlowDelegate?

    // MARK: - Initialization
    required init(dependencies: HasLoggers & HasLocationManager & HasUserManager & HasNetworkMonitor, delegate: SettingsBarFlowDelegate?) {
        self.delegate = delegate
        self.locationVM = .init(dependencies: dependencies)
        super.init()
    }
    
    // MARK: - Methods
    func logoutPressed() {
        // Simulate logout action
        if isOnline {
            // Perform normal logout
        } else {
            delegate?.logoutPressedWhileOffline()
        }
    }
    
    func profilePressed() {
        // Simulate profile button action
        delegate?.profilePressed()
    }
    
    func onboardingPressed() {
        // Simulate onboarding button action
        delegate?.onboardingPressed()
    }
    
    func hideProfileNavigationOption() {
        showProfileMenuOption = false
    }
}
