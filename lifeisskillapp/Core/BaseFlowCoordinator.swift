//
//  BaseFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.08.2024.
//

import Foundation
import UIKit
import ACKategories

public protocol BaseFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss()
}

// Provide a default implementation of the presentation method
extension BaseFlowCoordinator {
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController.frontmostController.present(viewController, animated: animated, completion: completion)
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController.presentedViewController?.dismiss(animated: true)
        }
    }
}
