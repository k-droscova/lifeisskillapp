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
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.setRegion(viewModel.region, animated: true)
        mapView.addAnnotations(viewModel.points.map { CustomMapAnnotation(point: $0) })
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
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
            if let cluster = annotation as? MKClusterAnnotation {
                // Customize the cluster annotation view
                let identifier = "ClusterAnnotationView"
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if clusterView == nil {
                    clusterView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                }
                
                // Determine the cluster color based on the first annotation type
                if let firstAnnotation = cluster.memberAnnotations.first as? CustomMapAnnotation {
                    clusterView?.markerTintColor = firstAnnotation.clusterColor
                } else {
                    clusterView?.markerTintColor = .gray // Default color if no annotations are found
                }
                
                // Hide the title and subtitle by setting them to nil
                clusterView?.canShowCallout = false
                clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
                clusterView?.titleVisibility = .hidden
                clusterView?.subtitleVisibility = .hidden
                return clusterView
            }
            
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
                annotationView?.bounds.size = icon.size
                annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Pin from the bottom center
            }
            
            // Enable clustering, cluster is identified by pointType (so points with same types are clustered together)
            annotationView?.clusteringIdentifier = customAnnotation.clusterIdentifier
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                // immediately deselect, we just want to zoom in
                mapView.deselectAnnotation(cluster, animated: false)
                let newClusterRegion = calculateRegionAfterClusterTapped(for: cluster)
                mapView.setRegion(newClusterRegion, animated: true)
            } else if let annotation = view.annotation as? CustomMapAnnotation,
                      let point = viewModel.points.first(where: { $0.id == annotation.id }) {
                // Animate the pin to a larger size when an individual annotation is selected
                UIView.animate(withDuration: 0.2) {
                    view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // 1.5x larger
                }
                // Call the method in the view model to handle the point tap
                viewModel.onPointTapped(point)
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            if view.annotation is MKClusterAnnotation {
                print("Cluster deselected")
            } else if view.annotation is CustomMapAnnotation {
                // Reset the pin to its original size when deselected
                UIView.animate(withDuration: 0.2) {
                    view.transform = .identity // Reset the transform to the original size
                }
                viewModel.onMapTapped()
            }
        }
        
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            print("DEBUG: Failed to locate user: \(error.localizedDescription)")
        }
        
        private func calculateRegionAfterClusterTapped(for cluster: MKClusterAnnotation) -> MKCoordinateRegion {
            // Calculate the bounding box of the annotations within the cluster
            var minLatitude: CLLocationDegrees = 90.0
            var maxLatitude: CLLocationDegrees = -90.0
            var minLongitude: CLLocationDegrees = 180.0
            var maxLongitude: CLLocationDegrees = -180.0
            
            for annotation in cluster.memberAnnotations {
                let coordinate = annotation.coordinate
                minLatitude = min(minLatitude, coordinate.latitude)
                maxLatitude = max(maxLatitude, coordinate.latitude)
                minLongitude = min(minLongitude, coordinate.longitude)
                maxLongitude = max(maxLongitude, coordinate.longitude)
            }
            
            // Calculate the center of the bounding box
            let centerLatitude = (minLatitude + maxLatitude) / 2.0
            let centerLongitude = (minLongitude + maxLongitude) / 2.0
            
            // Calculate the span (with some padding)
            let latitudeDelta = (maxLatitude - minLatitude) * 1.2 // Adding 20% padding
            let longitudeDelta = (maxLongitude - minLongitude) * 1.2 // Adding 20% padding
            
            // Create the region
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        }
    }
}
