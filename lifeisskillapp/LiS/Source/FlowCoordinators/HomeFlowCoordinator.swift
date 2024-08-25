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
    func onboardingPressed()
}

protocol HomeFlowDelegate: NSObject, ScanPointFlowDelegate {
    // MARK: - scanning flow
    func loadFromQR(viewModel: QRViewModeling)
    func dismissQR()
    func loadFromCamera(viewModel: OcrViewModeling)
    func dismissCamera()
    // MARK: - message flow
    func featureUnavailable(source: CodeSource)
    func onFailure(source: CodeSource)
    // MARK: - navigation
    func showOnboarding()
}

/// The HomeFlowCoordinator is responsible for managing the home flow within the app. It handles the navigation and actions from the home view controller.
final class HomeFlowCoordinator<csVM: CategorySelectorViewModeling, statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator, FlowCoordinatorAlertPresentable {
    /// The delegate to notify about the success of point loading.
    private weak var delegate: HomeFlowCoordinatorDelegate?
    private weak var homeVM: (any HomeViewModeling)?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    private var categorySelectorVM: csVM
    
    // MARK: - Initialization
    
    init(
        delegate: HomeFlowCoordinatorDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate? = nil,
        categorySelectorVM: csVM
    ) {
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
        self.categorySelectorVM = categorySelectorVM
    }
    
    /// Starts the home flow by presenting the home view controller.
    ///
    /// - Returns: The home view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = HomeViewModel<csVM, statusBarVM>(
            dependencies: .init(
                gameDataManager: appDependencies.gameDataManager,
                logger: appDependencies.logger,
                locationManager: appDependencies.locationManager,
                userDefaultsStorage: appDependencies.userDefaultsStorage,
                userManager: appDependencies.userManager,
                networkMonitor: appDependencies.networkMonitor
            ),
            categorySelectorVM: self.categorySelectorVM,
            delegate: self,
            settingsDelegate: self.settingsDelegate
        )
        self.homeVM = viewModel
        let vc = HomeView(viewModel: viewModel).hosting()
        self.rootViewController = vc
        let navController = UINavigationController(rootViewController: vc)
        self.navigationController = navController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        return navController
    }
}

extension HomeFlowCoordinator: HomeFlowDelegate {
    
    // MARK: - QR Flow
    
    func loadFromQR(viewModel: QRViewModeling) {
        let qrViewController = HomeQRView(viewModel: viewModel).hosting()
        qrViewController.modalPresentationStyle = .fullScreen
        present(qrViewController, animated: true)
    }
    
    func dismissQR() {
        returnToHomeScreen()
    }
    
    // MARK: - Camera Flow
    
    func loadFromCamera(viewModel: OcrViewModeling) {
        if #available(iOS 16.0, *) {
            let cameraViewController = HomeCameraOCRView(viewModel: viewModel).hosting()
            cameraViewController.modalPresentationStyle = .fullScreen
            present(cameraViewController, animated: true)
        } else {
            featureUnavailable(source: .text)
        }
    }
    
    func dismissCamera() {
        returnToHomeScreen()
    }
    
    func showOnboarding() {
        delegate?.onboardingPressed()
    }
}

extension HomeFlowCoordinator {
    func featureUnavailable(source: CodeSource) {
        appDependencies.logger.log(message: "feature unavailable")
        showAlert(
            titleKey: "home.scan_error.feature_unavailable.title",
            messageKey: "home.scan_error.feature_unavailable.message",
            completion: returnToHomeScreen
        )
    }
 
    func onSuccess(source: CodeSource) {
        returnToHomeScreen()
        appDependencies.logger.log(message: "scanning success for source: \(source.rawValue)")
        showSuccessAlert()
    }
    
    func onFailure(source: CodeSource) {
        returnToHomeScreen()
        appDependencies.logger.log(message: "scanning failure for source: \(source.rawValue)")
        showFailureAlert(source)
    }
    
    // MARK: - Private Helpers
    
    private func returnToHomeScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showSuccessAlert() {
        showAlert(titleKey: "home.scan_success.title", messageKey: "home.scan_success.message")
    }
    
    private func showFailureAlert(_ source: CodeSource) {
        switch source {
        case .qr:
            showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.qr.message")
        case .nfc:
            showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.nfc.message")
        case .virtual:
            showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.virtual.message")
        case .text:
            showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.text.message")
        case .unknown:
            showAlert(titleKey: "alert.general_error.title", messageKey: "alert.general_error.message")
        }
    }
}

extension HomeFlowCoordinator: ScanPointFlowDelegate {
    func onScanPointNoLocation() {
        returnToHomeScreen()
        showNoLocationAlert()
    }
    
    func onScanPointInvalidPoint() {
        returnToHomeScreen()
        showInvalidPointAlert()
    }
    
    func onScanPointProcessSuccessOnline(_ source: CodeSource) {
        returnToHomeScreen()
        appDependencies.logger.log(message: "scanning success for source: \(source.rawValue)")
        showOnlineSuccessAlert()
    }
    
    func onScanPointProcessSuccessOffline(_ source: CodeSource) {
        returnToHomeScreen()
        appDependencies.logger.log(message: "scanning success for source: \(source.rawValue)")
        showOfflineSuccessAlert()
    }
    
    func onScanPointOnlineProcessError(_ source: CodeSource) {
        returnToHomeScreen()
        appDependencies.logger.log(message: "scanning processing failure for source: \(source.rawValue)")
    }
    
    func onScanPointOfflineProcessError() {
        returnToHomeScreen()
        showOfflineFailureAlert()
    }
    
    // MARK: - Private Helpers
    
    private func returnToHomeScreen() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showNoLocationAlert() {
        showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.no_location")
    }
    
    private func showInvalidPointAlert() {
        showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.invalid_point")
    }
    
    private func showOnlineSuccessAlert() {
        showAlert(titleKey: "home.scan_success.title", messageKey: "home.scan_success.message_online")
    }
    
    private func showOfflineSuccessAlert() {
        showAlert(titleKey: "home.scan_success.title", messageKey: "home.scan_success.message_offline")
    }
    
    private func showOfflineFailureAlert() {
        showAlert(titleKey: "home.scan_error.title", messageKey: "home.scan_error.message_offline")
    }
 
extension HomeFlowCoordinator {
    @MainActor
    private func showAlert(titleKey: String, messageKey: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: NSLocalizedString(titleKey, comment: ""),
            message: NSLocalizedString(messageKey, comment: ""),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
