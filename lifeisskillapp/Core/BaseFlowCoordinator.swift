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
            guard let self = self else { return }
            guard let vc = self.findSuitableController(from: self.rootViewController) else { return }
            vc.present(viewController, animated: animated, completion: completion)
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController.presentedViewController?.dismiss(animated: true)
        }
    }
    
    /// Finds the last view controller in the hierarchy that is not being dismissed. Should be called from rootViewController
    private func findSuitableController(from controller: UIViewController) -> UIViewController? {
        // If the controller is being dismissed, return nil.
        if controller.isBeingDismissed {
            return nil
        }

        // Recursively check the presented view controller.
        if let presented = controller.presentedViewController {
            if let suitableController = findSuitableController(from: presented) {
                return suitableController
            }
        }

        // If no presented view controller or all presented view controllers are being dismissed,
        // return the current controller as it is the most suitable.
        return controller
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
