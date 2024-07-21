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
    private var mainFlowCoordinator: MainFlowCoordinator?
    
    override func start(in window: UIWindow) {
        self.window = window
        super.start(in: window)
        prepareWindow()
    }
    
    // MARK: - Private helpers
    
    private func prepareWindow() {
        if appDependencies.userManager.isLoggedIn {
            self.showHome()
        } else {
            self.showLogin()
        }
    }
    
    private func showHome() {
        DispatchQueue.main.async {
            self.stop(animated: true) // stops FCs to avoid memory leaks
            let mainFC = MainFlowCoordinator()
            mainFC.delegate = self
            let navigationController = UINavigationController()
            self.window?.rootViewController = navigationController
            self.rootViewController = self.window?.rootViewController
            mainFC.start(with: navigationController)
            self.addChild(mainFC)
            self.activeChild = mainFC
            self.mainFlowCoordinator = mainFC // Store a strong reference
        }
    }
    
    private func showLogin() {
        let loginFC = LoginFlowCoordinator()
        loginFC.delegate = self
        addChild(loginFC)
        let loginVC = loginFC.start()
        
        window?.rootViewController = loginVC
        rootViewController = window?.rootViewController
        window?.makeKeyAndVisible()
        self.mainFlowCoordinator = nil // Clear reference when switching to login
    }
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        prepareWindow()
    }
}

extension AppFlowCoordinator: MainFlowCoordinatorDelegate {
    func reload() {
        prepareWindow()
    }
}
