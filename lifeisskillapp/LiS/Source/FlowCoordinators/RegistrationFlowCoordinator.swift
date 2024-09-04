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
    func loadQR()
    func dismissQR()
    func showReferenceInstructions()
    func scanningQRDidSucceed()
    func scanningQRDidFail()
    func registrationDidSucceed()
    func registrationDidFail()
}

final class RegistrationFlowCoordinator: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var delegate: RegistrationFlowCoordinatorDelegate?
    
    init(delegate: RegistrationFlowCoordinatorDelegate? = nil) {
        self.delegate = delegate
        super.init()
    }
    
    override func start() -> UIViewController {
        super.start()
        
        let vm = RegistrationViewModel(dependencies: appDependencies, delegate: self)
        let vc = RegistrationView(viewModel: vm).hosting()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = vc
        return navigationController
    }
}

extension RegistrationFlowCoordinator: RegistrationFlowDelegate {
    func loadQR() {
        print("load qr")
    }
    
    func dismissQR() {
        dismiss()
    }
    
    func showReferenceInstructions() {
        
    }
    
    func scanningQRDidSucceed() {
        
    }
    
    func scanningQRDidFail() {
        
    }
    
    func registrationDidSucceed() {
        delegate?.registrationDidSucceed()
    }
    
    func registrationDidFail() {
        delegate?.registrationDidFail()
    }
}
