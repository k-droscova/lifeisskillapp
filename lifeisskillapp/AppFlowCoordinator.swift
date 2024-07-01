//
//  AppFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

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
        
        
        // MARK: Home
        let homeVC = HomeViewController()
        let homeNavigationController = UINavigationController(rootViewController: homeVC)
        homeNavigationController.tabBarItem.title = "Home"
        homeNavigationController.tabBarItem.image = UIImage(
            systemName: "home"
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            homeNavigationController
        ]
        
        rootViewController = tabBarController
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        self.tabBar = tabBarController
    }
    
    private func showLogin() {
        let loginController = LoginViewController()
        rootViewController = loginController
        window?.rootViewController = loginController
        window?.makeKeyAndVisible()
    }
    
    private func prepareWindow() {
        if appDependencies.userManager.isLoggedIn {
            setupTabBar()
        } else {
            stop()
            showLogin()
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
