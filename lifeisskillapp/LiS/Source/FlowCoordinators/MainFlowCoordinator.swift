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

final class MainFlowCoordinator: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator {
    weak var delegate: MainFlowCoordinatorDelegate?
    
    override init() {
        super.init()
        appDependencies.gameDataManager.delegate = self // present alert if any fatal error with game data occurs anywhere in the app
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
        
        // MARK: MAP
        
        let mapFC = MapFlowCoordinator<SettingsBarViewModel<LocationStatusBarViewModel>>(
            delegate: self,
            settingsDelegate: self
        )
        addChild(mapFC)
        let mapVC = mapFC.start()
        mapVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("map.title", comment: ""),
            image: Constants.TabBar.Map.unselected.icon,
            selectedImage: Constants.TabBar.Map.selected.icon
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
            delegate: self,
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
            mapVC,
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

extension MainFlowCoordinator: HomeFlowCoordinatorDelegate, PointsFlowCoordinatorDelegate, RankFlowCoordinatorDelegate, MapFlowCoordinatorDelegate {}

extension MainFlowCoordinator: SettingsBarFlowDelegate {
    func logoutPressedWhileOffline() {
        let okAction = Alert.okAction(style: .destructive) {
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
    
    // MARK: Settings not yet implemented, to be determined what settings will contain
    func settingsPressed() {
        print("Need to navigate to settings")
    }
    
    func profilePressed() {
        guard let navVC = self.navigationController else { return }
        let profileFC = ProfileFlowCoordinator<SettingsBarViewModel<LocationStatusBarViewModel>>(delegate: self, settingsDelegate: self)
        addChild(profileFC)
        activeChild = profileFC
        profileFC.start(with: navVC)
    }
    
    func onboardingPressed() {
        let onboardingVC = OnboardingView().hosting()
        onboardingVC.modalPresentationStyle = .formSheet
        present(onboardingVC, animated: true)
    }
}

extension MainFlowCoordinator: GameDataManagerFlowDelegate {
    func onInvalidToken() {
        appDependencies.userManager.forceLogout()
    }
    
    func storedScannedPointsFailedToSend() {
        showAlert(titleKey: "alert.scanning.processing.stored.title", messageKey: "alert.scanning.processing.stored.message")
    }
}

extension MainFlowCoordinator: ProfileFlowCoordinatorDelegate {
    func returnToHomeScreen() {
        if let child = activeChild {
            removeChild(child) // prevents mem leaks, deletes the profile FC when returned to tabbar
        }
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func generateQRDidFail() {
        showAlert(titleKey: "alert.qr_generating.error.title", messageKey: "alert.qr_generating.error.message")
    }
    
    func loadUserDataDidFail() {
        returnToHomeScreen()
        showAlert(titleKey: "alert.loading_user_profile.data.error.title", messageKey: "alert.loading_user_profile.data.error.message")
    }
}
