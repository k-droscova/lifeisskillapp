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

final class PointsFlowCoordinator<csVM: CategorySelectorViewModeling, statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink {
    private weak var delegate: PointsFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    private var categorySelectorVM: csVM
    
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
            settingsDelegate: self.settingsDelegate
        )
        let vc = PointsView(viewModel: viewModel).hosting()
        return vc
    }
}

extension PointsFlowCoordinator: PointsFlowDelegate {
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
