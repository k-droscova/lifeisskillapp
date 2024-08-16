//
//  AlertPresentable.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.08.2024.
//

import Foundation
import UIKit
import ACKategories

protocol AlertPresentable {
    var rootViewController: UIViewController? { get }
    
    func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)?)
    func showAlert(titleKey: String, messageKey: String, actions: [UIAlertAction])
    func onError(_ error: any Error)
}

extension AlertPresentable {
    func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completion?()
        }
        showAlert(titleKey: titleKey, messageKey: messageKey, actions: [okAction])
    }
    
    func showAlert(titleKey: String, messageKey: String, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            guard let rootVC = self.rootViewController else {
                return
            }
            
            let alertController = UIAlertController(
                title: NSLocalizedString(titleKey, comment: ""),
                message: NSLocalizedString(messageKey, comment: ""),
                preferredStyle: .alert
            )
            
            actions.forEach { alertController.addAction($0) }
            
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onError(_ error: any Error) {
        showAlert(
            titleKey: "alert.general_error.title",
            messageKey: "alert.general_error.message"
        )
    }
}

protocol FlowCoordinatorAlertPresentable: AlertPresentable {}

extension FlowCoordinatorAlertPresentable where Self: Base.FlowCoordinatorNoDeepLink {
    var rootViewController: UIViewController? {
        return self.rootViewController
    }
}

extension FlowCoordinatorAlertPresentable where Self: AppFlowCoordinator {
    var rootViewController: UIViewController? {
        return appRootViewController
    }
}
