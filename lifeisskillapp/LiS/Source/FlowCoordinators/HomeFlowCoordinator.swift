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
    func loadFromQR(viewModel: QRViewModeling)
    func dismissQR()
    func loadFromCamera(viewModel: OcrViewModeling)
    func dismissCamera()
    // MARK: - message flow
    func featureUnavailable(source: CodeSource)
    func onSuccess(source: CodeSource)
    func onFailure(source: CodeSource)
    // MARK: - navigation
    func showOnboarding()
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
        let viewModel = HomeViewModel(
            dependencies: .init(
                scanningManager: appDependencies.scanningManager,
                logger: appDependencies.logger,
                locationManager: appDependencies.locationManager,
                userLoginManager: appDependencies.userLoginManager
            ),
            delegate: self
        )
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
    
    func loadFromQR(viewModel: QRViewModeling) {
        let qrViewController = HomeQRViewController(viewModel: viewModel)
        qrViewController.modalPresentationStyle = .fullScreen
        navigationController?.present(qrViewController, animated: true, completion: nil)
    }
    
    func dismissQR() {
        returnToHomeScreen()
    }
    
    // MARK: - Camera Flow
    
    func loadFromCamera(viewModel: OcrViewModeling) {
        if #available(iOS 16.0, *) {
            let cameraViewController = HomeCameraOCRViewController(viewModel: viewModel)
            cameraViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(cameraViewController, animated: true, completion: nil)
        } else {
            self.featureUnavailable(source: .text)
        }
    }
    
    func dismissCamera() {
        returnToHomeScreen()
    }
    
    func showOnboarding() {
        // TODO: present Onboarding Controller when called
        appDependencies.logger.log(message: "Onboarding tapped")
    }
}

extension HomeFlowCoordinator {
    func featureUnavailable(source: CodeSource) {
        appDependencies.logger.log(message: "feature unavailable")
        self.showAlert(
            titleKey: "home.scan_error.feature_unavailable.title",
            messageKey: "home.scan_error.feature_unavailable.message",
            completion: self.returnToHomeScreen
        )
    }
    
    func onSuccess(source: CodeSource) {
        self.returnToHomeScreen()
        appDependencies.logger.log(message: "scanning success for source: \(source.rawValue)")
        self.showSuccessAlert()
    }
    
    func onFailure(source: CodeSource) {
        self.returnToHomeScreen()
        appDependencies.logger.log(message: "scanning failure for source: \(source.rawValue)")
        self.showFailureAlert(source)
    }
    
    // MARK: - Private Helpers
    
    private func returnToHomeScreen() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showSuccessAlert() {
        self.showAlert(titleKey: "home.scan_success.title", messageKey: "home.scan_success.message")
    }
    
    private func showFailureAlert(_ source: CodeSource) {
        switch source {
        case .qr:
            self.showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.qr.message")
        case .nfc:
            self.showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.nfc.message")
        case .virtual:
            self.showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.virtual.message")
        case .text:
            self.showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.text.message")
        }
    }
}

extension HomeFlowCoordinator {
    private func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        guard let navigationController = self.navigationController else {
            return
        }
        
        let alertController = UIAlertController(
            title: NSLocalizedString(titleKey, comment: ""),
            message: NSLocalizedString(messageKey, comment: ""),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        
        navigationController.present(alertController, animated: true, completion: nil)
    }
}
