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
    
    // Step Enum
    enum Step {
        case enterEmail
        case enterPin
        case enterPassword
    }
    
    private var currentStep: Step = .enterEmail
    private var previousStep: Step?
    
    init(delegate: ForgotPasswordFlowCoordinatorDelegate? = nil, viewModel: passwordVM) {
        self.delegate = delegate
        self.viewModel = viewModel
        
        super.init()
        viewModel.delegate = self
    }
    
    override func start() -> UIViewController {
        super.start()
        
        let vc = createViewController(for: .enterEmail)
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = vc
        return navigationController
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        super.presentationControllerDidDismiss(presentationController)
        delegate?.returnToLogin()
    }
    
    @MainActor
    private func navigateToCurrentStep(animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        
        // Determine if we need to pop or push based on previous and current steps
        if let previousStep = previousStep, shouldPop(from: previousStep, to: currentStep) {
            navigationController.popViewController(animated: animated)
        } else {
            let nextVC = createViewController(for: currentStep)
            navigationController.pushViewController(nextVC, animated: animated)
        }
    }
    
    @MainActor
    private func createViewController(for step: Step) -> UIViewController {
        switch step {
        case .enterEmail:
            return EnterEmailView(viewModel: self.viewModel).hosting()
        case .enterPin:
            return EnterPinView(viewModel: self.viewModel).hosting()
        case .enterPassword:
            return EnterPasswordView(viewModel: self.viewModel).hosting()
        }
    }
    
    @MainActor
    private func shouldPop(from previous: Step, to current: Step) -> Bool {
        // Determine if the transition is going back
        switch (previous, current) {
        case (.enterPassword, .enterPin):
            return true
        default:
            return false
        }
    }
    
    @MainActor
    private func proceedToNextStep() {
        previousStep = currentStep // Track the previous step
        switch currentStep {
        case .enterEmail:
            currentStep = .enterPin
        case .enterPin:
            currentStep = .enterPassword
        case .enterPassword:
            delegate?.forgotPasswordDidSucceed()
            return
        }
        navigateToCurrentStep()
    }
    
    @MainActor
    private func returnToPreviousStep() {
        previousStep = currentStep
        switch currentStep {
        case .enterEmail:
            currentStep = .enterEmail
            return
        case .enterPin:
            currentStep = .enterEmail
        case .enterPassword:
            currentStep = .enterPin
        }
        navigateToCurrentStep()
    }
}

extension ForgotPasswordFlowCoordinator: ForgotPasswordViewModelDelegate {
    func didRenewPassword() {
        proceedToNextStep()
    }
    
    func didValidatePin() {
        proceedToNextStep()
    }
    
    @MainActor
    func didRequestNewPin() {
        if currentStep == .enterEmail {
            proceedToNextStep()
        } else if currentStep == .enterPassword {
            returnToPreviousStep()
        }
        showAlert(titleKey: "forgot_password.alert.request.title", messageKey: "forgot_password.alert.request.message")
    }
    
    @MainActor
    func failedRequestNewPin() {
        showAlert(
            titleKey: "forgot_password.alert.request_error.title",
            messageKey: "forgot_password.alert.request_error.message"
        )
    }

    @MainActor
    func failedValidatePin() {
        showAlert(
            titleKey: "forgot_password.alert.pin_error.title",
            messageKey: "forgot_password.alert.pin_error.message"
        )
    }

    @MainActor
    func timerRanOut() {
        showAlert(
            titleKey: "forgot_password.alert.timer.title",
            messageKey: "forgot_password.alert.timer.message"
        ) { [weak self] in
            self?.delegate?.returnToLogin()
        }
    }

    @MainActor
    func failedRenewPassword() {
        showAlert(
            titleKey: "forgot_password.alert.password_error.title",
            messageKey: "forgot_password.alert.password_error.message"
        )
    }
}
