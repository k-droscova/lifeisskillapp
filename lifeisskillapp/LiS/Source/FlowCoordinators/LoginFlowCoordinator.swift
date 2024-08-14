//
//  LoginFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 12.07.2024.
//

import Foundation
import UIKit
import ACKategories

protocol LoginFlowCoordinatorDelegate: NSObject {
    func loginDidSucceed()
}

protocol LoginFlowDelegate: NSObject {
    func registerTapped()
    func forgotPasswordTapped()
    func loginSuccessful()
    func loginFailed()
    func offlineLoginFailed()
}

/// The LoginFlowCoordinator is responsible for managing the login flow within the app. It handles the navigation and actions from the login view controller.
final class LoginFlowCoordinator<statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink {
    private weak var delegate: LoginFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    
    // MARK: - Initialization
    
    init(
        delegate: LoginFlowCoordinatorDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate? = nil
    )
    {
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
    }
    
    /// Starts the login flow by presenting the login view controller.
    ///
    /// - Returns: The login view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = LoginViewModel<statusBarVM>(
            dependencies: appDependencies,
            delegate: self,
            settingsDelegate: self.settingsDelegate
        )
        let loginVC = LoginView(viewModel: viewModel).hosting()
        self.rootViewController = loginVC
        return loginVC
    }
}

extension LoginFlowCoordinator: LoginFlowDelegate {
    func registerTapped() {
        print("Register Tapped")
    }
    func forgotPasswordTapped() {
        print("Forgot Password Tapped")
    }
    func loginSuccessful() {
        delegate?.loginDidSucceed()
    }
    func loginFailed() {
        self.showOnlineLoginFailureAlert()
    }
    func offlineLoginFailed() {
        self.showOfflineLoginFailureAlert()
    }
    
    // MARK: - Private Helpers
    
    private func showOfflineLoginFailureAlert() {
        self.showAlert(titleKey: "login.error.title", messageKey: "login.error_offline.message")
    }
    
    private func showOnlineLoginFailureAlert() {
        self.showAlert(titleKey: "login.error.title", messageKey: "login.error_online.message")
    }
}

extension LoginFlowCoordinator {
    private func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        guard let rootVC = self.rootViewController else {
            return
        }
        
        let alertController = UIAlertController(
            title: NSLocalizedString(titleKey, comment: ""),
            message: NSLocalizedString(messageKey, comment: ""),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        
        rootVC.present(alertController, animated: true, completion: nil)
    }
}
