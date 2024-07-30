//
//  HomeFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import UIKit
import ACKategories
import SwiftUI

protocol HomeFlowCoordinatorDelegate: NSObject {
    
}

protocol HomeFlowDelegate: NSObject {
    // MARK: - scanning flow
    func loadFromQR()
    func dismissQR()
    func loadFromCamera(viewModel: OcrViewModeling)
    func dismissCamera()
    // MARK: - message flow
    func featureUnavailable()
    func onSuccess(source: CodeSource)
    func onFailure(source: CodeSource)
}

/// The HomeFlowCoordinator is responsible for managing the home flow within the app. It handles the navigation and actions from the home view controller.
final class HomeFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of point loading.
    private weak var delegate: HomeFlowCoordinatorDelegate?
    private weak var homeVM: HomeViewModeling?
    
    // MARK: - Initialization
    
    init(delegate: HomeFlowCoordinatorDelegate? = nil) {
        self.delegate = delegate
    }
    
    /// Starts the home flow by presenting the home view controller.
    ///
    /// - Returns: The home view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = HomeViewModel(dependencies: appDependencies, delegate: self)
        self.homeVM = viewModel
        let homeController = HomeViewController(viewModel: viewModel)
        self.rootViewController = homeController
        let navController = UINavigationController(rootViewController: homeController)
        self.navigationController = navController
        return navController
    }
}

extension HomeFlowCoordinator: HomeFlowDelegate {
    
    // MARK: - QR Flow
    
    func loadFromQR() {
        appDependencies.logger.log(message: "loading from qr")
    }
    
    func dismissQR() {
        appDependencies.logger.log(message: "dismissing qr")
    }
    
    // MARK: - Camera Flow
    
    func loadFromCamera(viewModel: OcrViewModeling) {
        if #available(iOS 16.0, *) {
            let cameraViewController = HomeCameraOCRViewController(viewModel: viewModel)
            cameraViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(cameraViewController, animated: true, completion: nil)
        } else {
            self.featureUnavailable()
        }
    }
    
    func dismissCamera() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension HomeFlowCoordinator {
    func featureUnavailable() {
        appDependencies.logger.log(message: "feature unavailable")
    }
    
    func onSuccess(source: CodeSource) {
        appDependencies.logger.log(message: "scanning success for source: \(source.rawValue)")
    }
    
    func onFailure(source: CodeSource) {
        appDependencies.logger.log(message: "scanning failure for source: \(source.rawValue)")
    }
}
