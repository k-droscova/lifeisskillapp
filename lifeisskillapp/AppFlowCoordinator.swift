//
//  AppFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import UIKit
import ACKategories

final class AppFlowCoordinator: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    private weak var window: UIWindow?
    
    override func start(in window: UIWindow) {
        self.window = window
        super.start(in: window)
        appDependencies.networkMonitor.delegate = self // present alert if connection lost on all screens
        appDependencies.locationManager.delegate = self // present alert to allow gps
        appDependencies.userManager.delegate = self // login logout
        prepareWindow()
    }
    
    // MARK: - Private helpers
    
    private func prepareWindow() {
        childCoordinators.forEach { $0.stop(animated: false) } // Prevents mem leaks, deallocates current/child FCs when screen switches
        if appDependencies.userManager.isLoggedIn {
            showHome()
        } else {
            showLogin()
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
        reload()
    }
}

extension AppFlowCoordinator: UserManagerFlowDelegate {
    func onLogout() {
        reload()
    }
    
    func onForceLogout() {
        reload()
        showAlert(titleKey: "alert.forced_logout.title", messageKey: "alert.forced_logout.message")
    }
}

extension AppFlowCoordinator: MainFlowCoordinatorDelegate {}

extension AppFlowCoordinator: NetworkManagerFlowDelegate {
    func onNoInternetConnection() {
        showAlert(titleKey: "alert.internet.lost_connection.title", messageKey: "alert.internet.lost_connection.message")
    }
}

extension AppFlowCoordinator: LocationManagerFlowDelegate {
    func onLocationUnsuccess() {
        showLocationAccessAlert()
    }

    private func showLocationAccessAlert() {
        let settingsAction = UIAlertAction(
            title: NSLocalizedString("settings.settings", comment: ""),
            style: .default
        ) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let exitAction = UIAlertAction(
            title: NSLocalizedString("alert.button.exit", comment: ""),
            style: .cancel
        ) { _ in
            // Exit the app when the user taps "Cancel"
            exit(0)
        }
        
        showAlert(
            titleKey: "location.access.title",
            messageKey: "location.access.message",
            actions: [settingsAction, exitAction]
        )
    }
}
