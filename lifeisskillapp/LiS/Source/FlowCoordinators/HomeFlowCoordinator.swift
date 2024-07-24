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
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromPhoto()
}

/// The LoginFlowCoordinator is responsible for managing the login flow within the app. It handles the navigation and actions from the login view controller.
final class HomeFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of the login process.
    weak var delegate: HomeFlowCoordinatorDelegate?

    /// Starts the login flow by presenting the login view controller.
    ///
    /// - Returns: The login view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = HomeViewModel(dependencies: appDependencies, delegate: self)
        let homeController = HomeViewController(viewModel: viewModel)
        self.rootViewController = homeController
        return homeController
    }
}

extension HomeFlowCoordinator: HomeFlowDelegate {
    func loadWithNFC() {
        print("NFC tapped")
    }
    
    func loadWithQRCode() {
        print("QR tapped")
    }
    
    func loadFromPhoto() {
        print("Photo tapped")
    }
}
