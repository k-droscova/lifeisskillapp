//
//  RegistrationFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.09.2024.
//

import Foundation
import UIKit
import ACKategories

protocol RegistrationFlowCoordinatorDelegate: NSObject {
    func registrationDidSucceed()
    func registrationDidFail()
    func returnToLogin()
}

protocol RegistrationFlowDelegate: NSObject {
    func loadQR(viewModel: QRViewModeling)
    func dismissQR()
    func showReferenceInstructions()
    func scanningQRDidSucceed(_ reference: ReferenceInfo)
    func scanningQRDidFail()
    func registrationDidSucceed()
    func registrationDidFail()
    func openLink(link: String)
}

final class RegistrationFlowCoordinator: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var delegate: RegistrationFlowCoordinatorDelegate?
    private var viewModel: (any RegistrationViewModeling)?
    
    init(delegate: RegistrationFlowCoordinatorDelegate? = nil) {
        self.delegate = delegate
        super.init()
    }
    
    override func start() -> UIViewController {
        super.start()
        
        let vm = RegistrationViewModel(
            dependencies: RegistrationViewModel.Dependencies(
                logger: appDependencies.logger,
                userManager: appDependencies.userManager
            ),
            delegate: self
        )
        self.viewModel = vm
        let vc = RegistrationView(viewModel: vm).hosting()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = vc
        return navigationController
    }
}

extension RegistrationFlowCoordinator: RegistrationFlowDelegate {
    func loadQR(viewModel: QRViewModeling) {
        let vc = QRReferenceView(viewModel: viewModel).hosting()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func dismissQR() {
        dismiss()
    }
    
    func showReferenceInstructions() {
        let vc = ReferenceDescriptionView().hosting()
        present(vc, animated: true)
    }
    
    func scanningQRDidSucceed(_ reference: ReferenceInfo) {
        dismissQR()
        showAlert(titleKey: "registration.reference.qr.success.title", messageKey: "registration.reference.qr.success.message")
        self.viewModel?.referenceInfo = reference
    }
    
    func scanningQRDidFail() {
        dismissQR()
        showAlert(titleKey: "registration.reference.qr.error.title", messageKey: "registration.reference.qr.error.message")
    }
    
    func registrationDidSucceed() {
        delegate?.registrationDidSucceed()
    }
    
    func registrationDidFail() {
        delegate?.registrationDidFail()
    }
    
    func openLink(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}
