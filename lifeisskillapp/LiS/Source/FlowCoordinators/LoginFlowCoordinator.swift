//
//  LoginFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 12.07.2024.
//

import Foundation
import UIKit
import ACKategories

/// A delegate protocol to handle events from the LoginFlowCoordinator.
protocol LoginFlowCoordinatorDelegate: NSObject {
    /// Called when the login process succeeds. This is called on AppFlowCoordinator to setup TabBar
    func loginDidSucceed()
}

/// A delegate protocol to handle actions within the LoginViewController.
protocol LoginFlowDelegate: NSObject {
    /// Called when the user taps the register button.
    ///
    /// - Parameter viewController: The view controller where the register button was tapped.
    func registerTapped(in viewController: LoginViewController?)

    /// Called when the login process is successful.
    ///
    /// - Parameter viewController: The view controller where the login process succeeded.
    func loginSuccessful(in viewController: LoginViewController?)
}

/// The LoginFlowCoordinator is responsible for managing the login flow within the app. It handles the navigation and actions from the login view controller.
final class LoginFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of the login process.
    weak var delegate: LoginFlowCoordinatorDelegate?

    /// Starts the login flow by presenting the login view controller.
    ///
    /// - Returns: The login view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = LoginViewModel(dependencies: appDependencies, delegate: self)
        let loginController = LoginViewController(viewModel: viewModel)
        loginController.delegate = self
        self.rootViewController = loginController
        return loginController
    }
}

// MARK: - LoginFlowDelegate
extension LoginFlowCoordinator: LoginFlowDelegate {
    /// Handles the event when the register button is tapped.
    ///
    /// - Parameter viewController: The view controller where the register button was tapped.
    func registerTapped(in viewController: LoginViewController?) {
        print("Register Tapped")
    }

    /// Handles the event when the login process is successful.
    ///
    /// - Parameter viewController: The view controller where the login process succeeded.
    func loginSuccessful(in viewController: LoginViewController?) {
        delegate?.loginDidSucceed()
    }
}
