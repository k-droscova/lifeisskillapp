//
//  AppFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import UIKit
import ACKategories

final class AppFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    private weak var window: UIWindow?
    
    override func start(in window: UIWindow) {
        self.window = window
        super.start(in: window)
        appDependencies.networkMonitor.delegate = self // present alert if connection lost on all screens
        appDependencies.userManager.delegate = self
        prepareWindow()
    }
    
    // MARK: - Private helpers
    
    private func prepareWindow() {
        childCoordinators.forEach { $0.stop(animated: false) } // Prevents mem leaks, deallocates current/child FCs when screen switches
        if appDependencies.userManager.isLoggedIn {
            self.showHome()
        } else {
            self.showLogin()
        }
    }
    
    private func showHome() {
        let mainFC = MainFlowCoordinator()
        mainFC.delegate = self
        self.addChild(mainFC)
        let mainVC = mainFC.start()
        
        window?.rootViewController = mainVC
        rootViewController = window?.rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func showLogin() {
        let loginFC = LoginFlowCoordinator<SettingsBarViewModel<LocationStatusBarViewModel>>(
            delegate: self
        )
        addChild(loginFC)
        let loginVC = loginFC.start()
        
        window?.rootViewController = loginVC
        rootViewController = window?.rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.prepareWindow()
        }
    }
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        self.reload()
    }
}

extension AppFlowCoordinator: UserManagerFlowDelegate {
    func onLogout() {
        self.reload()
    }
    
    func onForceLogout() {
        self.reload()
        showAlert(titleKey: "alert.forced_logout.title", messageKey: "alert.forced_logout.message")
    }
}

extension AppFlowCoordinator: MainFlowCoordinatorDelegate {}

extension AppFlowCoordinator: NetworkManagerFlowDelegate {
    func onNoInternetConnection() {
        showAlert(titleKey: "alert.internet.lost_connection.title", messageKey: "alert.internet.lost_connection.message")
    }
}

extension AppFlowCoordinator {
    private func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let rootVC = self.window?.rootViewController else {
                return
            }
            
            let alertController = UIAlertController(
                title: NSLocalizedString(titleKey, comment: ""),
                message: NSLocalizedString(messageKey, comment: ""),
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                completion?()
            }
            alertController.addAction(okAction)
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
}
