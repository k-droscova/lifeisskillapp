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
    func pointLoadingSuccess()
    func pointLoadingFailure()
    func featureUnavailable()
}

protocol HomeFlowDelegate: NSObject {
    func loadingSuccessNFC()
    func loadingFailureNFC()
    func loadingSuccessQR()
    func loadingFailureQR()
    func loadingSuccessCamera()
    func loadingFailureCamera()
    func loadingSuccessVirtual()
    func loadingFailureVirtual()
    func loadFromCamera()
    func dismissCamera()
    func invalidSign()
}

/// The HomeFlowCoordinator is responsible for managing the home flow within the app. It handles the navigation and actions from the home view controller.
final class HomeFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of point loading.
    private weak var delegate: HomeFlowCoordinatorDelegate?
    private weak var viewModel: HomeViewModeling?
    
    // MARK: - Initialization
    
    init(delegate: HomeFlowCoordinatorDelegate? = nil) {
        self.delegate = delegate
    }
    
    /// Starts the home flow by presenting the home view controller.
    ///
    /// - Returns: The home view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = HomeViewModel(dependencies: appDependencies, delegate: self)
        self.viewModel = viewModel
        let homeController = HomeViewController(viewModel: viewModel)
        self.rootViewController = homeController
        let navController = UINavigationController(rootViewController: homeController)
        self.navigationController = navController
        return navController
    }
}

extension HomeFlowCoordinator: HomeFlowDelegate {
    func loadingSuccessVirtual() {
        delegate?.pointLoadingSuccess()
    }
    
    func loadingFailureVirtual() {
        delegate?.pointLoadingFailure()
    }
    
    func loadingSuccessQR() {
        delegate?.pointLoadingSuccess()
    }
    
    func loadingFailureQR() {
        delegate?.pointLoadingFailure()
    }
    
    func loadingSuccessCamera() {
        delegate?.pointLoadingSuccess()
    }
    
    func loadingFailureCamera() {
        delegate?.pointLoadingFailure()
    }
    
    func loadingSuccessNFC() {
        delegate?.pointLoadingSuccess()
    }
    
    func loadingFailureNFC() {
        delegate?.pointLoadingFailure()
    }
    func invalidSign() {
        delegate?.pointLoadingFailure()
    }
    func loadFromCamera() {
        guard let viewModel = viewModel else { return }
        if #available(iOS 16.0, *) {
            let cameraViewController = HomeCameraOCRViewController(viewModel: viewModel)
            cameraViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(cameraViewController, animated: true, completion: nil)
        } else {
            delegate?.featureUnavailable()
        }
    }

    func dismissCamera() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
