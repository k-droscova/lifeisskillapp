//
//  PointsFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import Foundation
import ACKategories
import UIKit

protocol PointsFlowCoordinatorDelegate: NSObject {

}

protocol PointsFlowDelegate: GameDataManagerFlowDelegate, NSObject {
    func onError(_ error: Error)
    func onNoDataAvailable()
    func selectCategoryPrompt()
}

final class PointsFlowCoordinator<csVM: CategorySelectorViewModeling>: Base.FlowCoordinatorNoDeepLink {
    private weak var delegate: PointsFlowCoordinatorDelegate?
    private var categorySelectorVM: csVM
    
    // MARK: - Initialization
    
    init(delegate: PointsFlowCoordinatorDelegate? = nil, categorySelectorVM: csVM) {
        self.delegate = delegate
        self.categorySelectorVM = categorySelectorVM
    }
    
    override func start() -> UIViewController {
        let viewModel = PointsViewModel(
            dependencies: appDependencies,
            categorySelectorVM: self.categorySelectorVM,
            delegate: self
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
