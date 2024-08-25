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
    func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)?)
    func showAlert(titleKey: String, messageKey: String, actions: [UIAlertAction])
    func onError(_ error: any Error)
}

extension BaseFlowCoordinator {
    
    // MARK: - Presenting and dismissing UIViewController
    
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
    
    // MARK: - Presenting Alerts
    
    func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completion?()
        }
        showAlert(titleKey: titleKey, messageKey: messageKey, actions: [okAction])
    }
    
    func showAlert(titleKey: String, messageKey: String, actions: [UIAlertAction]) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(
                title: NSLocalizedString(titleKey, comment: ""),
                message: NSLocalizedString(messageKey, comment: ""),
                preferredStyle: .alert
            )
            
            actions.forEach { alertController.addAction($0) }
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onError(_ error: any Error) {
        showAlert(
            titleKey: "alert.general_error.title",
            messageKey: "alert.general_error.message"
        )
    }
}
