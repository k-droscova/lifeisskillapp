//
//  HomeQRViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import ACKategories
import SwiftUI

@available(iOS 16.0, *)
final class HomeQRViewController: Base.ViewController {
    private let viewModel: QRViewModeling
    
    // MARK: - Initialization
    
    init(viewModel: QRViewModeling) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let rootView = HomeQRView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
