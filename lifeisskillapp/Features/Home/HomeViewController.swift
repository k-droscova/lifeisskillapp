//
//  HomeViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import ACKategories
import SwiftUI

final class HomeViewController: Base.ViewController {
    let viewModel: HomeViewModeling
    
    // MARK: - Initialization
    
    override init() {
        self.viewModel = HomeViewModel(
            dependencies: .init(userManager: appDependencies.userManager)
        )
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let rootView = HomeView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Home"
    }
}
