//
//  SettingsBarViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import Foundation

protocol SettingsBarFlowDelegate: NSObject {
    func settingsPressed()
    func cameraPressed()
    func onboardingPressed()
}

protocol SettingsBarViewModeling: BaseClass, ObservableObject {
    associatedtype locationStatusBarVM: LocationStatusBarViewModeling
    var locationVM: locationStatusBarVM { get }
    var isLoggedIn: Bool { get }
    func logoutPressed()
    func cameraPressed()
    func settingsPressed()
    func onboardingPressed()
    init(dependencies: any HasUserDefaultsStorage & HasLoggers & HasLocationManager & HasUserManager, delegate: SettingsBarFlowDelegate?)

}

final class SettingsBarViewModel<locationVM: LocationStatusBarViewModeling>: BaseClass, ObservableObject, SettingsBarViewModeling {
    typealias Dependencies = HasUserDefaultsStorage & HasLoggers & HasLocationManager & HasUserManager
    
    // MARK: - Private Properties
    
    private weak var delegate: SettingsBarFlowDelegate?
    private let logger: LoggerServicing
    private let userManager: UserManaging
    
    // MARK: - Public Properties
    
    var locationVM: locationVM
    var isLoggedIn: Bool {
        userManager.isLoggedIn
    }
    
    // MARK: - Initialization
    
    required init(dependencies: Dependencies, delegate: SettingsBarFlowDelegate?) {
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.delegate = delegate
        self.locationVM = locationVM.init(dependencies: dependencies)
    }
    
    // MARK: - Public Interface
    
    func logoutPressed() {
        userManager.logout()
    }
    
    func cameraPressed() {
        delegate?.cameraPressed()
    }
    
    func settingsPressed() {
        delegate?.settingsPressed()
    }
    
    func onboardingPressed() {
        delegate?.onboardingPressed()
    }
}
