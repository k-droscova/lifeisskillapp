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
    private weak var tabBar: UITabBarController?

    
    override func start(in window: UIWindow) {
        self.window = window
        
        super.start(in: window)
        
        appDependencies.userManager.delegate = self
        prepareWindow()
    }
    
    // MARK: - Private helpers
    
    private func setupTabBar() {
        guard tabBar == nil, appDependencies.userManager.isLoggedIn else { return }
        
        
        Task { @MainActor in
            
            
            // MARK: - HOME
            
            let homeVC = HomeViewController()
            let homeNavigationController = UINavigationController(rootViewController: homeVC)
            homeNavigationController.tabBarItem.title = "Home"
            homeNavigationController.tabBarItem.image = UIImage(systemName: "house")
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [homeNavigationController]
            
            self.rootViewController = tabBarController
            
            self.window?.rootViewController = tabBarController
            self.window?.makeKeyAndVisible()
            
            self.tabBar = tabBarController
        }
        
        
    }
    
    private func showLogin() {
        Task { @MainActor in
            let loginFlowCoordinator = LoginFlowCoordinator()
            loginFlowCoordinator.delegate = self
            addChild(loginFlowCoordinator)
            let loginVC = LoginViewController()
            window?.rootViewController = loginVC
            rootViewController = window?.rootViewController
            activeChild = loginFlowCoordinator
            
        }
    }
    
    private func prepareWindow() {
        if !appDependencies.userManager.hasAppId {
            Task {
                try await appDependencies.userManager.initializeAppId()
            }
        }
        Task { @MainActor in
            if appDependencies.userManager.isLoggedIn {
                self.setupTabBar()
            } else {
                self.stop()
                self.showLogin()
            }
        }
    }
    
}



extension AppFlowCoordinator: UserManagerFlowDelegate {
    func onLogin() {
        prepareWindow()
    }
    
    func onLogout() {
        prepareWindow()
    }
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        prepareWindow()
    }
}
