//
//  HomeViewFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 12.07.2024.
//

import Foundation
import UIKit
import ACKategories
import SwiftUI

protocol MainFlowCoordinatorDelegate: NSObject {
    func reload()
}

protocol MainFlowDelegate: NSObject {
    
}

final class MainFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    private weak var tabBarController: UITabBarController?
    private var pointsNC: UINavigationController?
    weak var delegate: MainFlowCoordinatorDelegate?
    
    override func start(with navigationController: UINavigationController) {
        guard tabBarController == nil, appDependencies.userManager.isLoggedIn else { return }
        appDependencies.userManager.delegate = self
        appDependencies.locationManager.delegate = self
        self.setupTabBar()
        guard let tabBarController else {
            return
        }
        self.navigationController = navigationController
        navigationController.setViewControllers([tabBarController], animated: true)
        rootViewController = navigationController
    }
    
    // MARK: - Private helpers
    private func setupTabBar() {
        // MARK: HOME
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("home.title", comment: ""),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // MARK: - SETUP TabBar
        let tabVC = UITabBarController()
        tabVC.viewControllers = [
            homeVC
        ]
        tabVC.tabBar.tintColor = UIColor.theme.lisPink
        tabVC.selectedViewController = homeVC
        self.tabBarController = tabVC
    }
}

extension MainFlowCoordinator: UserManagerFlowDelegate {
    func onLogout() {
        delegate?.reload()
    }
    func onDataError(_ error: Error) {
        // TODO: HANDLE ERROR BETTER
        do {
            throw BaseError(context: .system, message: error.localizedDescription, logger: appDependencies.logger)
        } catch {
            let alert = UIAlertController(title: "Data Fetching Error", message: "Failed to get data: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.setupTabBar()
            })
            rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension MainFlowCoordinator: LocationManagerFlowDelegate {
    func onLocationUnsuccess() {
        showLocationAccessAlert()
    }
    
    private func showLocationAccessAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "Please enable location services in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.setupTabBar()
        })
        rootViewController?.present(alert, animated: true, completion: nil)
    }
}
