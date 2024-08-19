//
//  MapViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import Foundation
import Combine
import MapKit


protocol MapViewModeling: BaseClass, ObservableObject {
    var mapDelegate: MapViewFlowDelegate? { get set }
    var points: [GenericPoint] { get }
    var region: MKCoordinateRegion { get set }
    var selectedPoint: GenericPoint? { get set }
    var cameraBoundary: MKMapView.CameraBoundary? { get set }
    var cameraZoomRange: MKMapView.CameraZoomRange? { get set }
    var userLocation: UserLocation? { get }
    
    func onAppear()
    func onPointTapped(_ point: GenericPoint)
    func onMapTapped()
}

extension MapViewModeling {
    func configureMapRegion(points: [Point]) {
        guard let point = points.first else {
            self.configureMapRegion(location: userLocation)
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
        self.selectedPoint = point
        mapDelegate?.onPointTapped(for: point)
    }
    
    func onMapTapped() {
        print("DEBUG: onMapTapped called")
        self.selectedPoint = nil
        mapDelegate?.onMapTapped()
    }
}
