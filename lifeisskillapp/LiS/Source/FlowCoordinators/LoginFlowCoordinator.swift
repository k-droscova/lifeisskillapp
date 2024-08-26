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
final class LoginFlowCoordinator<statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var delegate: LoginFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    
    // MARK: - Initialization
    
    init(
        delegate: LoginFlowCoordinatorDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate? = nil
    )
    {
        super.init()
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
    }
    
    /// Starts the login flow by presenting the login view controller.
    ///
    /// - Returns: The login view controller to be presented.
    override func start() -> UIViewController {
        super.start()
        
        let viewModel = LoginViewModel<statusBarVM>(
            dependencies: appDependencies,
            delegate: self,
            settingsDelegate: self.settingsDelegate
        )
        let loginVC = LoginView(viewModel: viewModel).hosting()
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = loginVC
        
        return navigationController
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        returnToLogin()
    }
}

extension LoginFlowCoordinator: LoginFlowDelegate {
    func registerTapped() {
        print("Register Tapped")
    }
    func forgotPasswordTapped() {
        print("Forgot password tapped")
        let forgetPasswordVM = ForgotPasswordViewModel(dependencies: appDependencies)
        let forgetPasswordFC = ForgotPasswordFlowCoordinator(delegate: self, viewModel: forgetPasswordVM)
        addChild(forgetPasswordFC)
        let vc = forgetPasswordFC.start()
        // TODO: figure out how to call returnToLogin on dismiss of vc
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    func loginSuccessful() {
        delegate?.loginDidSucceed()
    }
    func loginFailed() {
        showOnlineLoginFailureAlert()
    }
    func offlineLoginFailed() {
        showOfflineLoginFailureAlert()
    }
    
    // MARK: - Private Helpers
    
    private func showOfflineLoginFailureAlert() {
        showAlert(titleKey: "login.error.title", messageKey: "login.error_offline.message")
    }
    
    private func showOnlineLoginFailureAlert() {
        showAlert(titleKey: "login.error.title", messageKey: "login.error_online.message")
    }
}

extension LoginFlowCoordinator: ForgotPasswordFlowCoordinatorDelegate {
    func forgotPasswordDidSucceed() {
        returnToLogin()
        let alert = UIAlertController(
            title: NSLocalizedString("forgot_password.alert.success.title", comment: ""),
            message: NSLocalizedString("forgot_password.alert.success.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        present(alert, animated: true)
    }

    func returnToLogin() {
        reload()
        dismiss()
    }
    
    private func reload() {
        childCoordinators.forEach { $0.stop(animated: false) } // Prevents mem leaks, deallocates current/child FCs when screen switches
    }
}
