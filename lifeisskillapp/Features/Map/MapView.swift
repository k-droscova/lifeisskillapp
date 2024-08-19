//
//  MapView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import SwiftUI
import MapKit

struct MapView<ViewModel: MapViewModeling>: UIViewRepresentable {
    @StateObject var viewModel: ViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addAnnotations(viewModel.points.map { CustomMapAnnotation(point: $0) })
        
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

        // Update annotations or any other properties if needed
        if uiView.annotations.isEmpty {
            uiView.addAnnotations(viewModel.points.map { CustomMapAnnotation(point: $0) })
        }
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
                annotationView?.canShowCallout = false // Allows the annotation to show callouts (e.g., title)
            } else {
                annotationView?.annotation = customAnnotation
            }
            
            // Set the custom icon as the entire annotation view
            if let icon = customAnnotation.icon {
                annotationView?.image = icon
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            print("DEBUG: Annotation selected")
            if let annotation = view.annotation as? CustomMapAnnotation {
                print("DEBUG: Selected annotation with ID: \(annotation.id)")
                if let point = viewModel.points.first(where: { $0.id == annotation.id }) {
                    print("DEBUG: Corresponding point found: \(point.pointName)")
                    viewModel.onPointTapped(point)
                } else {
                    print("DEBUG: No corresponding point found for ID: \(annotation.id)")
                }
            } else {
                print("DEBUG: Selected annotation is not a CustomMapAnnotation")
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            print("DEBUG: Annotation deselected")
            viewModel.onMapTapped()
        }
    }
}
