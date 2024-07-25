//
//  HomeViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import ACKategories
import SwiftUI

final class HomeViewController: Base.ViewController {
    private let viewModel: HomeViewModeling
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModeling) {
        self.viewModel = viewModel
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
        navigationItem.title = "home.title"
    }
}
