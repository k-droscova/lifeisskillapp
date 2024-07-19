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
        appDependencies.locationManager.delegate = self
        prepareWindow()
    }
    
    // MARK: - Private helpers
    
    private func setupTabBar() {
        guard tabBar == nil, appDependencies.userManager.isLoggedIn else { return }
        Task { @MainActor in
            
            // MARK: - HOME
            
            let homeVC = HomeViewController()
            let homeNavigationController = UINavigationController(rootViewController: homeVC)
            homeNavigationController.tabBarItem = UITabBarItem(
                        title: NSLocalizedString("home.title", comment: ""),
                        image: UIImage(systemName: "house"),
                        selectedImage: UIImage(systemName: "house.fill")
            )
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [homeNavigationController]
            
            self.rootViewController = tabBarController
            
            self.window?.rootViewController = tabBarController
            self.window?.makeKeyAndVisible()
            
            self.tabBar = tabBarController
        }
    }
    
    private func showLogin() {
        Task {
            @MainActor in
            let loginFC = LoginFlowCoordinator()
            loginFC.delegate = self
            addChild(loginFC)
            let loginVC = loginFC.start()
            window?.rootViewController = loginVC
            rootViewController = window?.rootViewController
            activeChild = loginFC
            self.window?.makeKeyAndVisible()
        }
    }
    
    private func prepareWindow() {
        Task {
            [weak self] in
            self?.childCoordinators.forEach { $0.stop() }
        }
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
    func onLogout() {
        prepareWindow()
    }
    func onDataError(_ error: Error) {
        // TODO: HANDLE ERROR BETTER
        do {
            throw BaseError(context: .system, message: error.localizedDescription, logger: appDependencies.logger)
        } catch {
            let alert = UIAlertController(title: "Data Fetching Error", message: "Failed to get data: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.prepareWindow()
            })
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        prepareWindow()
    }
}

extension AppFlowCoordinator: LocationManagerFlowDelegate {
    func onLocationUnsuccess() {
        appDependencies.logger.log(message: "Location Manager - UNSUCCESS")
        showLocationAccessAlert()
    }
    
    func onLocationSuccess() {
        appDependencies.logger.log(message: "Location Manager - SUCCESS")
    }
    
    private func showLocationAccessAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "Please enable location services in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.prepareWindow()
        })
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func onLocationError(_ error: Error) {
        // TODO: HANDLE ERROR BETTER
        do {
            throw BaseError(context: .location, message: error.localizedDescription, logger: appDependencies.logger)
        } catch {
            let alert = UIAlertController(title: "Location Error", message: "Failed to get location: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.prepareWindow()
            })
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
