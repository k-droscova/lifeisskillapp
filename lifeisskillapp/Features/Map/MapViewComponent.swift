//
//  MapView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import SwiftUI
import MapKit

struct MapViewComponent<ViewModel: MapViewModeling>: UIViewRepresentable {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addAnnotations(viewModel.points.map { CustomMapAnnotation(point: $0) })
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        // Apply the region and camera settings
        mapView.setRegion(viewModel.region, animated: true)
        if let boundary = viewModel.cameraBoundary {
            mapView.cameraBoundary = boundary
        }
        if let zoomRange = viewModel.cameraZoomRange {
            mapView.cameraZoomRange = zoomRange
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        // Add the updated annotations
        let newAnnotations = viewModel.points.map { CustomMapAnnotation(point: $0) }
        uiView.addAnnotations(newAnnotations)
        
        uiView.setRegion(viewModel.region, animated: true)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomMapAnnotation else {
                return nil
            }
            
            let identifier = "CustomAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = customAnnotation
            }
            
            if let icon = customAnnotation.icon {
                annotationView?.image = icon
                // Store the original size
                annotationView?.bounds.size = icon.size
                annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Pin from the bottom center
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            print("DEBUG: Annotation selected")
            
            // Animate the pin to a larger size when selected
            UIView.animate(withDuration: 0.2) {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // 1.5x larger
            }
            
            if let annotation = view.annotation as? CustomMapAnnotation {
                if let point = viewModel.points.first(where: { $0.id == annotation.id }) {
                    viewModel.onPointTapped(point)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            print("DEBUG: Annotation deselected")
            
            // Animate the pin back to its original size when deselected
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity // Reset the transform to the original size
            }
            
            viewModel.onMapTapped()
        }
        
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            print("DEBUG: Failed to locate user: \(error.localizedDescription)")
        }
    }
}
