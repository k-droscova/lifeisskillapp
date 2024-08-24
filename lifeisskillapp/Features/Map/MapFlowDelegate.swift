//
//  MapFlowDelegate.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.08.2024.
//

import Foundation
import UIKit

protocol MapViewFlowDelegate: BaseFlowCoordinator {    
    func onPointTapped(for point: GenericPoint)
    func onMapTapped()
    func onError(_ error: Error)
}

extension MapViewFlowDelegate {
    func onPointTapped(for point: GenericPoint) {
        let vc = MapPointDetailView(point: point).hosting()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom(resolver: { context in
                return MapConstants.mapDetailViewSheetHeight
            })
            
            sheet.detents = [smallDetent]
            sheet.selectedDetentIdentifier = smallDetent.identifier
            sheet.prefersGrabberVisible = false
            sheet.largestUndimmedDetentIdentifier = smallDetent.identifier
        }
        vc.isModalInPresentation = true 
        present(vc, animated: true)
    }
    
    func onMapTapped() {
        dismiss()
    }
}
