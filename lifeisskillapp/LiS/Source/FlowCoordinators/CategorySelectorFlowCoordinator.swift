//
//  CategorySelectorFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import Foundation
import UIKit
import ACKategories

protocol CategorySelectorCoordinatorDelegate: NSObject {
    
}

protocol CategorySelectorDelegate: NSObject {
    func onError(_ error: Error)
}

final class CategorySelectorCoordinator: Base.FlowCoordinatorNoDeepLink {
    weak var delegate: CategorySelectorCoordinatorDelegate?
    
    override func start() -> UIViewController {
        let viewModel = CategorySelectorViewModel(dependencies: appDependencies)
        let vc = CategorySelectorView(viewModel: viewModel).hosting()
        self.rootViewController = vc
        return vc
    }
}

extension CategorySelectorCoordinator: CategorySelectorDelegate {
    func onError(_ error: any Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}
