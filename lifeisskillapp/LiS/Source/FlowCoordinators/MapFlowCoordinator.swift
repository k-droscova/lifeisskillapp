//
//  MapFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.08.2024.
//

import Foundation
import ACKategories
import UIKit

protocol MapFlowCoordinatorDelegate: NSObject {}

final class MapFlowCoordinator<statusBarVM: SettingsBarViewModeling>: Base.FlowCoordinatorNoDeepLink {
    private weak var delegate: MapFlowCoordinatorDelegate?
    private weak var settingsDelegate: SettingsBarFlowDelegate?
    private var viewModel: (any MapViewModeling)?
    
    // MARK: - Initialization
    
    init(
        delegate: MapFlowCoordinatorDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate? = nil
    ) {
        self.delegate = delegate
        self.settingsDelegate = settingsDelegate
    }
    
    override func start() -> UIViewController {
        let viewModel = MapViewModel<statusBarVM>(
            dependencies: appDependencies,
            mapDelegate: self,
            settingsDelegate: self.settingsDelegate
        )
        self.viewModel = viewModel
        let vc = MapView(viewModel: viewModel).hosting()
        self.rootViewController = vc
        let navController = UINavigationController(rootViewController: vc)
        self.navigationController = navController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        return navController
    }
}

extension MapFlowCoordinator: MapViewFlowDelegate {
    func onError(_ error: any Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    var root: UIViewController? { self.navigationController }
}
