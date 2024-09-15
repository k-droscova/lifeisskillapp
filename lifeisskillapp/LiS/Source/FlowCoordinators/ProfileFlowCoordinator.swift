//
//  ProfileFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import Foundation
import UIKit
import ACKategories

protocol ProfileFlowCoordinatorDelegate: NSObject {
    func returnToHomeScreen()
    func generateQRDidFail()
    func loadUserDataDidFail()
}

protocol ProfileFlowDelegate: NSObject {
    func generateQR(content: UIImage)
    func generateQRDidFail()
    func returnToHomeScreen()
    func startRegistration()
    func loadUserDataDidFail()
    func emailRequestNotSent()
    func emailRequestDidSucceed()
    func emailRequestDidFail()
}

final class ProfileFlowCoordinator<statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    
    private weak var delegate: ProfileFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    private weak var viewModel: (any ProfileViewModeling)?
    
    
    init(delegate: ProfileFlowCoordinatorDelegate? = nil,
         settingsDelegate: SettingsBarFlowDelegate? = nil
    ) {
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
        super.init()
    }
    
    override func start(with navigationController: UINavigationController) {
        let vm = ProfileViewModel<statusBarVM>(
            dependencies: appDependencies,
            delegate: self,
            settingsDelegate: self.settingsDelegate
        )
        self.viewModel = vm
        let vc = ProfileView(viewModel: vm).hosting()
        self.navigationController = navigationController
        rootViewController = vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        stopChildCoordinators()
    }
}

extension ProfileFlowCoordinator: ProfileFlowDelegate {
    func emailRequestNotSent() {
        showAlert(titleKey: "profile.email_request.error.title", messageKey: "profile.email_request.error_not_sent.message")
    }
    
    func emailRequestDidSucceed() {
        showAlert(titleKey: "profile.email_request.success.title", messageKey: "profile.email_request.success.message")
    }
    
    func emailRequestDidFail() {
        showAlert(titleKey: "profile.email_request.error.title", messageKey: "profile.email_request.error.message")
    }
    
    func generateQR(content: UIImage) {
        let vc = InviteFriendView(qrImage: content).hosting()
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    func generateQRDidFail() {
        delegate?.generateQRDidFail()
    }
    
    func returnToHomeScreen() {
        delegate?.returnToHomeScreen()
    }
    
    func startRegistration() {
        let fullRegistrationFC = FullRegistrationFlowCoordinator(delegate: self)
        addChild(fullRegistrationFC)
        let vc = fullRegistrationFC.start()
        vc.modalPresentationStyle = .formSheet
        vc.presentationController?.delegate = self
        present(vc, animated: true)
    }
    
    func loadUserDataDidFail() {
        delegate?.loadUserDataDidFail()
    }
}

extension ProfileFlowCoordinator: FullRegistrationFlowCoordinatorDelegate {
    func registrationDidSucceedAdult() {
        dismiss()
        stopChildCoordinators()
        showAlert(titleKey: "full_registration.success.title", messageKey: "full_registration.success.message")
        viewModel?.reloadDataAfterRegistration()
    }
    
    func registrationDidSucceedMinor() {
        dismiss()
        stopChildCoordinators()
        showAlert(titleKey: "full_registration.success.title", messageKey: "full_registration.success_minor.message")
        viewModel?.reloadDataAfterRegistration()
    }
    
    func registrationDidFail() {
        showAlert(titleKey: "full_registration.error.title", messageKey: "full_registration.error.message")
    }
}
