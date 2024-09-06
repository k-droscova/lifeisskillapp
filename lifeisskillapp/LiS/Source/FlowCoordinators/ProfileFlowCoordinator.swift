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
}

final class ProfileFlowCoordinator<statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    
    private weak var delegate: ProfileFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    
    
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
        print("start registration pressed")
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
    func registrationDidSucceed() {
        dismiss()
        stopChildCoordinators()
        showAlert(titleKey: "full_registration.success.title", messageKey: "full_registration.success.message")
    }
    
    func registrationDidFail() {
        showAlert(titleKey: "full_registration.error.title", messageKey: "full_registration.error.message")
    }
}
