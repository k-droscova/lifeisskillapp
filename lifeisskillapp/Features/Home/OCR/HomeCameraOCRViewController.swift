//
//  HomeCameraOCRViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.07.2024.
//

import ACKategories
import SwiftUI

@available(iOS 16.0, *)
final class HomeCameraOCRViewController: Base.ViewController {
    private let viewModel: OcrViewModeling
    
    // MARK: - Initialization
    
    init(viewModel: OcrViewModeling) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let rootView = HomeCameraOCRView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
