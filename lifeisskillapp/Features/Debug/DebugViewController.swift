//
//  HomeViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import ACKategories
import SwiftUI

final class DebugViewController: Base.ViewController {
    let viewModel: DebugViewModeling
    
    // MARK: - Initialization
    
    override init() {
        self.viewModel = DebugViewModel(
            dependencies: appDependencies
        )
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let vc = DebugView(viewModel: viewModel).hosting()
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
