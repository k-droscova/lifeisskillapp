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
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        DispatchQueue.main.async { [weak self] in
            self?.prepareWindow()
        }
    }
    
    func loginDidFail() {
        let alert = UIAlertController(title: "Login Failed", message: "Please check that you used the correct username and password. If you forgot your password, click the button below to reset it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        
        DispatchQueue.main.async { [weak self] in
            self?.prepareWindow()
            self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppFlowCoordinator: MainFlowCoordinatorDelegate {
    func onForceLogout() {
        self.reload()
        let alert = UIAlertController(title: "Forced logout", message: "It was detected that you have logged in on another device. It is not permitted to be logged in on multiple devices, hence we logged you out on this device.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.prepareWindow()
        }
    }
}

extension AppFlowCoordinator: NetworkManagerFlowDelegate {
    func onNoInternetConnection() {
        let alert = UIAlertController(title: "Internet Connection Lost", message: "Please be aware that the network is not available. Only most recently logged in user can log in again. You can scan points as usual, but if you log out before accessing network, all scanned points will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        rootViewController?.present(alert, animated: true, completion: nil)
    }
}
