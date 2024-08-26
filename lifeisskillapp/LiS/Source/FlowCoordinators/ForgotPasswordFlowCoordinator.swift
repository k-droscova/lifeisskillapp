//
//  ForgotPasswordFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation
import UIKit
import ACKategories

protocol ForgotPasswordFlowCoordinatorDelegate: NSObject {
    func forgotPasswordDidSucceed()
    func returnToLogin()
}

final class ForgotPasswordFlowCoordinator<passwordVM: ForgotPasswordViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var delegate: ForgotPasswordFlowCoordinatorDelegate?
    private var viewModel: passwordVM
    
    // Step Enum (defined inside the coordinator)
    enum Step {
        case enterEmail
        case enterPin
        case enterPassword
    }
    private var currentStep: Step = .enterEmail
    
    init(delegate: ForgotPasswordFlowCoordinatorDelegate? = nil, viewModel: passwordVM) {
        self.delegate = delegate
        self.viewModel = viewModel
        
        super.init()
        viewModel.delegate = self
    }
    
    override func start() -> UIViewController {
        super.start()
        
        let vc = EnterEmailView(viewModel: self.viewModel).hosting()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = vc
        return navigationController
    }
    
    // TODO: figure out how to stop this FC when I dismiss the form sheet
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        super.presentationControllerDidDismiss(presentationController)
        delegate?.returnToLogin()
    }
    
    @MainActor
    private func showCurrentStep() {
        var nextVC: UIViewController
        switch currentStep {
        case .enterEmail:
            nextVC = EnterEmailView(viewModel: self.viewModel).hosting()
        case .enterPin:
            nextVC = EnterPinView(viewModel: self.viewModel).hosting()
        case .enterPassword:
            nextVC = EnterPasswordView(viewModel: self.viewModel).hosting()
        }
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @MainActor
    private func goToPinSent() {
        navigationController?.popToRootViewController(animated: false)
        currentStep = .enterEmail
        goToNextStep()
    }
    
    private func goToNextStep() {
        switch currentStep {
        case .enterEmail:
            currentStep = .enterPin
        case .enterPin:
            currentStep = .enterPassword
        case .enterPassword:
            delegate?.forgotPasswordDidSucceed()
        }
        showCurrentStep()
    }
}

extension ForgotPasswordFlowCoordinator: ForgotPasswordViewModelDelegate {
    func timerRanOut() {
        let alert = UIAlertController(
            title: NSLocalizedString("forgot_password.alert.timer.title", comment: ""),
            message: NSLocalizedString("forgot_password.alert.timer.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.delegate?.returnToLogin() })
        present(alert, animated: true, completion: nil)
    }
    
    func didRenewPassword() {
        goToNextStep()
    }
    
    @MainActor
    func didRequestNewPin() {
        goToPinSent()  // Move to next step after email is sent
        let alert = UIAlertController(
            title: NSLocalizedString("forgot_password.alert.request.title", comment: ""),
            message: NSLocalizedString("forgot_password.alert.request.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        present(alert, animated: true, completion: nil)
    }
    
    func didValidatePin() {
        goToNextStep()  // Move to next step after PIN is validated
    }
    
    @MainActor
    func failedRenewPassword() {
        let alert = UIAlertController(
            title: NSLocalizedString("forgot_password.alert.error.title", comment: ""),
            message: NSLocalizedString("forgot_password.alert.error.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        present(alert, animated: true, completion: nil)
    }
}
