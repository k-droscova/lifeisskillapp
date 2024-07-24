//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation

protocol HomeViewModeling {
    func pointScanned(pointID: String, source: CodeSource)
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromPhoto()
}

final class HomeViewModel: HomeViewModeling, ObservableObject {
    typealias Dependencies = HasUserManager
    
    weak var delegate: HomeFlowDelegate?
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.delegate = delegate
    }
    
    func pointScanned(pointID: String, source: CodeSource) {
        print("point scanned")
    }
    
    func loadWithNFC() {
        delegate?.loadWithNFC()
    }
    
    func loadWithQRCode() {
        delegate?.loadWithQRCode()
    }
    
    func loadFromPhoto() {
        delegate?.loadFromPhoto()
    }
}
