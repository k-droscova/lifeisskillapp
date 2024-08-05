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
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        rootViewController = tabBarVC
        
        return navigationController
    }
    
    // MARK: - Private helpers
    
    private func setupTabBar() -> UITabBarController{
        // MARK: DEBUG
        let debugVM = DebugViewModel(dependencies: appDependencies)
        let debugVC = DebugView(viewModel: debugVM).hosting()
        debugVC.tabBarItem = UITabBarItem(
            title: "debug",
            image: UIImage(systemName: "ladybug.circle"),
            selectedImage: UIImage(systemName: "ladybug.circle.fill")
        )
        
        // MARK: CATEGORY SELECTOR
        let csFC = CategorySelectorCoordinator()
        addChild(csFC)
        let csVC = csFC.start()
        
        // MARK: HOME
        let homeFC = HomeFlowCoordinator(delegate: self, categorySelectorVC: csVC)
        addChild(homeFC)
        let homeVC = homeFC.start()
        homeVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("home.title", comment: ""),
            image: Constants.TabBar.Home.unselected.icon,
            selectedImage: Constants.TabBar.Home.selected.icon
        )
        
        // MARK: RANK
        let rankFC = RankFlowCoordinator(categorySelectorVC: csVC)
        addChild(rankFC)
        let rankVC = rankFC.start()
        rankVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("rank.title", comment: ""),
            image: Constants.TabBar.Rank.unselected.icon,
            selectedImage: Constants.TabBar.Rank.selected.icon
        )
        
        // MARK: - SETUP TabBar
        let tabVC = UITabBarController()
        tabVC.viewControllers = [
            debugVC,
            homeVC,
            rankVC
        ]
        tabVC.selectedViewController = homeVC
        customizeTabBarAppearance(tabBar: tabVC.tabBar)
        return tabVC
    }
    
    private func customizeTabBarAppearance(tabBar: UITabBar) {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = CustomColors.TabBar.background.color
            
            appearance.stackedLayoutAppearance.selected.iconColor = CustomColors.TabBar.selectedItem.color
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.TabBar.selectedItem.color]
            
            appearance.stackedLayoutAppearance.normal.iconColor = CustomColors.TabBar.unselectedItem.color
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.TabBar.unselectedItem.color]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = CustomColors.TabBar.background.color
            tabBar.tintColor = CustomColors.TabBar.selectedItem.color
            tabBar.unselectedItemTintColor = CustomColors.TabBar.unselectedItem.color
        }
    }
}

extension MainFlowCoordinator {
    enum Constants {
        enum TabBar {
            enum Home {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Home.pink.rawValue)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Home.pink.rawValue)
                    }
                }
            }
            enum Rank {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Rank.pink.rawValue)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Rank.black.rawValue)
                    }
                }
            }
            enum Points {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Profile.pink.rawValue)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Profile.black.rawValue)
                    }
                }
            }
            enum Map {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Map.pink.rawValue)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Map.black.rawValue)
                    }
                }
            }
        }
    }
}

extension MainFlowCoordinator: UserManagerFlowDelegate {
    func onLogout() {
        delegate?.reload()
    }
    func onDataError(_ error: Error) {
        // TODO: HANDLE ERROR BETTER
        appDependencies.logger.log(message: "ERROR: \(error.localizedDescription)")
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
