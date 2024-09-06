//
//  FullRegistrationFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.09.2024.
//

import Foundation
import ACKategories
import UIKit

protocol FullRegistrationFlowCoordinatorDelegate: NSObject {
    func registrationDidSucceed()
    func registrationDidFail()
}

protocol FullRegistrationFlowDelegate: NSObject {
    func registrationDidSucceed()
    func registrationDidFail()
}

final class FullRegistrationFlowCoordinator: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var delegate: FullRegistrationFlowCoordinatorDelegate?
    
    init(delegate: FullRegistrationFlowCoordinatorDelegate? = nil) {
        self.delegate = delegate
        super.init()
    }
    
    override func start() -> UIViewController {
        super.start()
        
        let vm = FullRegistrationViewModel(
            dependencies: appDependencies,
            delegate: self)
        let vc = FullRegistrationView(viewModel: vm).hosting()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = vc
        return navigationController
    }
}

extension FullRegistrationFlowCoordinator: FullRegistrationFlowDelegate {
    func registrationDidSucceed() {
        delegate?.registrationDidSucceed()
    }
    
    func registrationDidFail() {
        delegate?.registrationDidFail()
    }
}
