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

protocol MainFlowCoordinatorDelegate: NSObject {}

final class MainFlowCoordinator: Base.FlowCoordinatorNoDeepLink, FlowCoordinatorAlertPresentable {
    weak var delegate: MainFlowCoordinatorDelegate?
    
    override init() {
        super.init()
        appDependencies.locationManager.delegate = self // MainFC presents alerts linked to location, since we need location AFTER login for point scanning
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
        // MARK: CATEGORY SELECTOR
        let csVM = CategorySelectorViewModel(dependencies: appDependencies)
        
        // MARK: POINTS
        let pointsFC = PointsFlowCoordinator<CategorySelectorViewModel, SettingsBarViewModel<LocationStatusBarViewModel>>(
            delegate: self,
            settingsDelegate: self,
            categorySelectorVM: csVM
        )
        addChild(pointsFC)
        let pointsVC = pointsFC.start()
        pointsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("points.title", comment: ""),
            image: Constants.TabBar.Points.unselected.icon,
            selectedImage: Constants.TabBar.Points.selected.icon
        )
        
        // MARK: HOME
        let homeFC = HomeFlowCoordinator<CategorySelectorViewModel, SettingsBarViewModel<LocationStatusBarViewModel>>(
            delegate: self,
            settingsDelegate: self,
            categorySelectorVM: csVM
        )
        addChild(homeFC)
        let homeVC = homeFC.start()
        homeVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("home.title", comment: ""),
            image: Constants.TabBar.Home.unselected.icon,
            selectedImage: Constants.TabBar.Home.selected.icon
        )
        appDependencies.userPointManager.scanningDelegate = homeFC // homeFC handles alerts related to point scanning
        
        // MARK: RANK
        let rankFC = RankFlowCoordinator<CategorySelectorViewModel, SettingsBarViewModel<LocationStatusBarViewModel>>(
            settingsDelegate: self,
            categorySelectorVM: csVM
        )
        
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
            pointsVC,
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
                        UIImage(named: CustomImages.TabBar.Home.pink.fullPath)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Home.pink.fullPath)
                    }
                }
            }
            enum Rank {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Rank.pink.fullPath)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Rank.black.fullPath)
                    }
                }
            }
            enum Points {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Profile.pink.fullPath)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Profile.black.fullPath)
                    }
                }
            }
            enum Map {
                case selected, unselected
                var icon: UIImage? {
                    switch self {
                    case .selected:
                        UIImage(named: CustomImages.TabBar.Map.pink.fullPath)
                    case .unselected:
                        UIImage(named: CustomImages.TabBar.Map.black.fullPath)
                    }
                }
            }
        }
    }
}

extension MainFlowCoordinator: LocationManagerFlowDelegate {
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
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("alert.button.cancel", comment: ""),
            style: .cancel
        )
        
        showAlert(
            titleKey: "location.access.title",
            messageKey: "location.access.message",
            actions: [settingsAction, cancelAction]
        )
    }
}

extension MainFlowCoordinator: HomeFlowCoordinatorDelegate, PointsFlowCoordinatorDelegate, RankFlowCoordinatorDelegate {}

extension MainFlowCoordinator: SettingsBarFlowDelegate {
    func logoutPressedWhileOffline() {
        let okAction = UIAlertAction(
            title: NSLocalizedString("alert.button.ok", comment: ""),
            style: .default
        ) { _ in
            appDependencies.userManager.offlineLogout()
        }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("alert.button.cancel", comment: ""),
            style: .cancel
        )
        
        showAlert(
            titleKey: "alert.logout_offline.title",
            messageKey: "alert.logout_offline.message",
            actions: [okAction, cancelAction]
        )
    }
    
    // TODO: NEED TO IMPLEMENT NAVIGATION TO DIFFERENT VIEWS
    func settingsPressed() {
        print("Need to navigate to settings")
    }
    
    func cameraPressed() {
        print("need to open camera")
    }
    
    func onboardingPressed() {
        let onboardingVC = OnboardingView().hosting()
        onboardingVC.modalPresentationStyle = .formSheet
        rootViewController?.present(onboardingVC, animated: true, completion: nil)
    }
}
