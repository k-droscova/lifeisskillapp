//
//  MapViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import Foundation
import Combine
import MapKit

protocol MapViewFlowDelegate: NSObject {
    var root: UIViewController? { get }
    func onPointTapped(for point: GenericPoint)
    func onMapTapped()
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
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = smallDetent.identifier
        }
        
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
        root.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

protocol MapViewModeling: BaseClass, ObservableObject {
    var mapDelegate: MapViewFlowDelegate? { get set }
    var points: [GenericPoint] { get }
    var region: MKCoordinateRegion { get set }
    var selectedPoint: GenericPoint? { get }
    var cameraBoundary: MKMapView.CameraBoundary? { get set }
    var cameraZoomRange: MKMapView.CameraZoomRange? { get set }
    
    func onAppear()
    func onPointTapped(_ point: GenericPoint)
    func onMapTapped()
}

extension MapViewModeling {
    func configureMapRegion(points: [Point]) {
        guard let point = points.first else {
            self.configureDefaultMapRegion()
            return
        }
        self.region = MKCoordinateRegion(
            center: point.location.toCLLocation().coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
        if #available(iOS 17.0, *) {
            self.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
            self.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: MapConstants.maxCenterCoordinateDistance)
        }
    }
    
    func configureMapRegion(location: UserLocation? = nil) {
        guard let location else {
            self.configureDefaultMapRegion()
            return
        }
        self.region = MKCoordinateRegion(
            center: location.toCLLocation().coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
        if #available(iOS 17.0, *) {
            self.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
            self.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: MapConstants.maxCenterCoordinateDistance)
        }
    }
    
    private func configureDefaultMapRegion() {
        self.region = MKCoordinateRegion(
            center: MapConstants.defaultCoordinate.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
        if #available(iOS 17.0, *) {
            self.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
            self.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: MapConstants.maxCenterCoordinateDistance)
        }
    }
}

extension MapViewModeling {
    func onPointTapped(_ point: GenericPoint) {
        print("DEBUG: onPointTapped called with point: \(point.pointName)")
        mapDelegate?.onPointTapped(for: point)
    }
    
    func onMapTapped() {
        print("DEBUG: onMapTapped called")
        mapDelegate?.onMapTapped()
    }
}
