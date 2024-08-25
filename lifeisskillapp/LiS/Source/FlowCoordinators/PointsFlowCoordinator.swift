//
//  PointsFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import Foundation
import ACKategories
import UIKit

protocol PointsFlowCoordinatorDelegate: NSObject {}

protocol PointsFlowDelegate: NSObject {
    func onError(_ error: Error)
    func onNoDataAvailable()
    func selectCategoryPrompt()
}

final class PointsFlowCoordinator<csVM: CategorySelectorViewModeling, statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink, BaseFlowCoordinator, MapViewFlowDelegate {
    private weak var delegate: PointsFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    private var categorySelectorVM: csVM
    private var viewModel: (any PointsViewModeling)?
    
    // MARK: - Initialization
    
    init(
        delegate: PointsFlowCoordinatorDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate? = nil,
        categorySelectorVM: csVM
    ) {
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
        self.categorySelectorVM = categorySelectorVM
    }
    
    override func start() -> UIViewController {
        let viewModel = PointsViewModel<csVM, statusBarVM>(
            dependencies: appDependencies,
            categorySelectorVM: self.categorySelectorVM,
            delegate: self,
            mapDelegate: self,
            settingsDelegate: self.settingsDelegate
        )
        self.viewModel = viewModel
        let vc = PointsView(viewModel: viewModel).hosting()
        self.rootViewController = vc
        let navController = UINavigationController(rootViewController: vc)
        self.navigationController = navController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        return navController
    }
}

extension PointsFlowCoordinator: PointsFlowDelegate {
    func onNoDataAvailable() {
        print("No data available")
    }
    
    func selectCategoryPrompt() {
        print("Please select category")
    }
}
