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
    weak var delegate: MainFlowCoordinatorDelegate?

    override init() {
        super.init()
        appDependencies.userManager.delegate = self
        appDependencies.locationManager.delegate = self
    }

    override func start() -> UIViewController {
        super.start()

        let tabBarVC = setupTabBar()
        let navigationController = UINavigationController(rootViewController: tabBarVC)
        self.navigationController = navigationController
        rootViewController = tabBarVC

        return navigationController
    }
    
    // MARK: - Private helpers
    
    private func setupTabBar() -> UITabBarController{
        // MARK: DEBUG
        let debugVC = DebugViewController()
        debugVC.tabBarItem = UITabBarItem(
            title: "debug",
            image: UIImage(systemName: "ladybug.circle"),
            selectedImage: UIImage(systemName: "ladybug.circle.fill")
        )
        
        // MARK: HOME
        let homeFC = HomeFlowCoordinator(delegate: self)
        addChild(homeFC)
        let homeVC = homeFC.start()
        homeVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("home.title", comment: ""),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // MARK: - SETUP TabBar
        let tabVC = UITabBarController()
        tabVC.viewControllers = [
            debugVC,
            homeVC
        ]
        tabVC.tabBar.tintColor = UIColor.theme.lisPink
        tabVC.selectedViewController = homeVC
        return tabVC
    }
}

extension MainFlowCoordinator: UserManagerFlowDelegate {
    func onLogout() {
        delegate?.reload()
    }
    func onDataError(_ error: Error) {
        // TODO: HANDLE ERROR BETTER
        _ = LogEvent(
            message: "Error: \(error.localizedDescription)",
            context: .system,
            severity: .error,
            logger: appDependencies.logger
        )
        let alert = UIAlertController(title: "Data Fetching Error", message: "Failed to get data: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in

        })
        rootViewController?.present(alert, animated: true, completion: nil)
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

        })
        rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension MainFlowCoordinator: HomeFlowCoordinatorDelegate {
    
}
