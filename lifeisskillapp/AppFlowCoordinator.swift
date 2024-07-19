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
            self.checkLocationAuthorization()
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
            self.checkLocationAuthorization()

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
    func fetchAllNewData() async {
        await fetchNewUserPoints()
        await fetchNewUserEvents()
        await fetchNewUserRank()
        await fetchNewUserMessages()
        await fetchNewPoints()
    }
    
    func fetchNewUserPoints() async {
        appDependencies.logger.log(message: "Updating userPointsData")
        do {
            try await appDependencies.userPointManager.fetch()
            guard let newCheckSumUserPoints = appDependencies.userPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: appDependencies.logger)
            }
            appDependencies.userManager.updateCheckSum(newCheckSum: newCheckSumUserPoints, type: CheckSumData.CheckSumType.userPoints)
        } catch {
            
        }
    }
    
    func fetchNewUserRank() async {
        appDependencies.logger.log(message: "Updating user rank")
    }
    
    func fetchNewUserMessages() async {
        appDependencies.logger.log(message: "Updating user messages")
    }
    
    func fetchNewUserEvents() async {
        appDependencies.logger.log(message: "Updating user events")
    }
    
    func fetchNewPoints() async {
        appDependencies.logger.log(message: "Updating generic points")
        do {
            try await appDependencies.genericPointManager.fetch()
            guard let newCheckSum = appDependencies.genericPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: appDependencies.logger)
            }
            appDependencies.userManager.updateCheckSum(newCheckSum: newCheckSum, type: CheckSumData.CheckSumType.points)
        } catch {
            
        }
    }
    
    func onLogout() {
        prepareWindow()
    }
    
}

extension AppFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginDidSucceed() {
        Task {
            try await appDependencies.userCategoryManager.fetch()
            try await appDependencies.userManager.checkCheckSumData()
        }
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
    
    private func checkLocationAuthorization() {
        appDependencies.locationManager.checkLocationAuthorization()
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
