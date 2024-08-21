//
//  MapFlowDelegate.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.08.2024.
//

import Foundation
import UIKit

protocol MapViewFlowDelegate: NSObject {
    var root: UIViewController? { get }
    
    func onPointTapped(for point: GenericPoint)
    func onMapTapped()
    func onError(_ error: Error)
}

extension MapViewFlowDelegate {
    func onPointTapped(for point: GenericPoint) {
        print("DEBUG: onPointTapped in Delegate for point: \(point.pointName)")
        guard let root = root else {
            print("DEBUG: Root view controller is nil")
            return
        }
        let vc = MapDetailView(point: point).hosting()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom(resolver: { context in
                return 150 // Adjust the height as needed
            })
            
            sheet.detents = [smallDetent]
            sheet.selectedDetentIdentifier = smallDetent.identifier
            sheet.prefersGrabberVisible = false
            sheet.largestUndimmedDetentIdentifier = smallDetent.identifier
        }
        vc.isModalInPresentation = true 
        
        DispatchQueue.main.async {
            root.present(vc, animated: true) {
                print("DEBUG: Sheet presentation called on main thread")
            }
        }
    }
    
    func onMapTapped() {
        print("DEBUG: onMapTapped in Delegate")
        guard let root = root else {
            print("DEBUG: Root view controller is nil")
            return
        }
        DispatchQueue.main.async {
            root.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
