//
//  HomeFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import UIKit
import ACKategories

protocol HomeFlowCoordinatorDelegate: NSObject {
    func pointLoadingSuccess()
    func pointLoadingFailure()
}

protocol HomeFlowDelegate: NSObject {
    func loadingSuccessNFC()
    func loadingFailureNFC()
}

/// The HomeFlowCoordinator is responsible for managing the home flow within the app. It handles the navigation and actions from the home view controller.
final class HomeFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of point loading.
    weak var delegate: HomeFlowCoordinatorDelegate?

    /// Starts the home flow by presenting the home view controller.
    ///
    /// - Returns: The home view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = HomeViewModel(dependencies: appDependencies, delegate: self)
        let homeController = HomeViewController(viewModel: viewModel)
        self.rootViewController = homeController
        return homeController
    }
}

extension HomeFlowCoordinator: HomeFlowDelegate {
    func loadingSuccessNFC() {
        delegate?.pointLoadingSuccess()
    }
    
    func loadingFailureNFC() {
        delegate?.pointLoadingFailure()
    }
}
