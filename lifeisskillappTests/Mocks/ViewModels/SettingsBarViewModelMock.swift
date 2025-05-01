//
//  SettingsBarViewModelMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import SwiftUI
@testable import lifeisskillapp

final class SettingsBarViewModelMock<locationVM: LocationStatusBarViewModeling>: BaseClass, SettingsBarViewModeling {
    
    // MARK: - Properties
    var isOnline: Bool = false
    var isGpsOk: Bool = false
    var isLoggedIn: Bool = false
    var showProfileMenuOption: Bool = true
    var userLocation: UserLocation? = nil
    var appVersion: String = "DEBUG"
    var locationVM: locationVM
    
    // Delegate to track actions
    private weak var delegate: SettingsBarFlowDelegate?

    // Initialization
    required init(dependencies: HasLoggers & HasLocationManager & HasUserManager & HasNetworkMonitor, delegate: SettingsBarFlowDelegate?) {
        self.delegate = delegate
        self.locationVM = .init(dependencies: dependencies)
        super.init()
    }
    
    // Methods
    func logoutPressed() {
        if isOnline {
            // Perform normal logout
        } else {
            delegate?.logoutPressedWhileOffline()
        }
    }
    
    func profilePressed() {
        delegate?.profilePressed()
    }
    
    func onboardingPressed() {
        delegate?.onboardingPressed()
    }
    
    func hideProfileNavigationOption() {
        showProfileMenuOption = false
    }
}
