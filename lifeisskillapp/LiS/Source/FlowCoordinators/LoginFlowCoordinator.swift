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
        let alert = UIAlertController(title: "Login Failed", message: "Please check that you used the correct username and password. If you forgot your password, click the button below to reset it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func offlineLoginFailed() {
        let alert = UIAlertController(title: "Login Failed", message: "You are offline. Only the most recently logged in user can log in in offline mode. Ensure you used the correct credentials for log in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
