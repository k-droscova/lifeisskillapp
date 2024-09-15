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
    func promptToCompleteRegistration()
    func promptParentToActivateAccount()
}

protocol LoginFlowDelegate: NSObject {
    func registerTapped()
    func forgotPasswordTapped()
    func loginSuccessful()
    func loginFailed()
    func offlineLoginFailed()
    func promptToCompleteRegistration()
    func promptParentToActivateAccount()
    func userNotActivated()
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
        stopChildCoordinators()
    }
}

extension LoginFlowCoordinator: LoginFlowDelegate {
    func registerTapped() {
        let registrationFC = RegistrationFlowCoordinator(delegate: self)
        addChild(registrationFC)
        let vc = registrationFC.start()
        vc.modalPresentationStyle = .formSheet
        vc.presentationController?.delegate = self
        present(vc, animated: true)
    }
    
    func forgotPasswordTapped() {
        let forgetPasswordVM = ForgotPasswordViewModel(dependencies: appDependencies)
        let forgetPasswordFC = ForgotPasswordFlowCoordinator(delegate: self, viewModel: forgetPasswordVM)
        addChild(forgetPasswordFC)
        let vc = forgetPasswordFC.start()
        vc.modalPresentationStyle = .formSheet
        vc.presentationController?.delegate = self // ensures that returnToLogin() is called on presentation dismissal
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
    
    func promptToCompleteRegistration() {
        delegate?.promptToCompleteRegistration()
    }
    
    func promptParentToActivateAccount() {
        delegate?.promptParentToActivateAccount()
    }
    
    func userNotActivated() {
        showAlert(titleKey: "alert.login_unactivated_user.title", messageKey: "alert.login_unactivated_user.message")
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
        showAlert(titleKey: "forgot_password.alert.success.title", messageKey: "forgot_password.alert.success.message")
    }
    
    func returnToLogin() {
        dismiss()
        stopChildCoordinators()
    }
}

extension LoginFlowCoordinator: RegistrationFlowCoordinatorDelegate {
    func registrationDidSucceed() {
        dismiss()
        showAlert(titleKey: "register.success.title", messageKey: "register.success.message")
    }
    
    func registrationDidFail() {
        showAlert(titleKey: "register.error.title", messageKey: "register.error.message")
    }
}
