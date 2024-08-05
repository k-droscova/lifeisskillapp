//
//  RankFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import Foundation
import UIKit
import ACKategories
import SwiftUI

protocol RankFlowCoordinatorDelegate: NSObject {
    
}

protocol RankFlowDelegate: GameDataManagerFlowDelegate, NSObject {
    func onError(_ error: Error)
    func onNoDataAvailable()
    func selectCategoryPrompt()
}

/// The HomeFlowCoordinator is responsible for managing the home flow within the app. It handles the navigation and actions from the home view controller.
final class RankFlowCoordinator: Base.FlowCoordinatorNoDeepLink {
    /// The delegate to notify about the success of point loading.
    private weak var delegate: RankFlowCoordinatorDelegate?
    private let categorySelectorVC: UIViewController
    
    // MARK: - Initialization
    
    init(delegate: RankFlowCoordinatorDelegate? = nil, categorySelectorVC: UIViewController) {
        self.delegate = delegate
        self.categorySelectorVC = categorySelectorVC
    }
    
    /// Starts the home flow by presenting the home view controller.
    ///
    /// - Returns: The home view controller to be presented.
    override func start() -> UIViewController {
        let viewModel = RankViewModel(dependencies: appDependencies, delegate: self)
        let vc = RankView(viewModel: viewModel, categorySelectorVC: self.categorySelectorVC).hosting()
        return vc
    }
}

extension RankFlowCoordinator: RankFlowDelegate {
    
    // TODO: present approppriate alerts
    
    func onError(_ error: any Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    
    func onNoDataAvailable() {
        print("No data available")
    }
    
    func selectCategoryPrompt() {
        print("Please select category")
    }
}
