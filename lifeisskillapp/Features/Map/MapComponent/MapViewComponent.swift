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
        context.coordinator.mapView = mapView
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
        
        // MARK: - Private Properties
        
        /// Maximum zoom level to trigger clustering behavior.
        /// Credit: Adapted from StackOverflow - https://stackoverflow.com/questions/46827353/mkmap-ios11-clusters-doesnt-split-up-after-max-zoom-how-to-set-it-up
        private let maxZoomLevel = MapConstants.maxClusterZoomLevel
        private var previousZoomLevel: Double?
        private var currentZoomLevel: Double? {
            willSet {
                self.previousZoomLevel = self.currentZoomLevel
            }
            didSet {
                /// Updates annotations if the zoom level crosses the max zoom threshold.
                /// Removes and re-adds annotations to enable/disable clustering as needed.
                guard let currentZoomLevel = self.currentZoomLevel,
                      let previousZoomLevel = self.previousZoomLevel else { return }
                if (currentZoomLevel > maxZoomLevel && previousZoomLevel <= maxZoomLevel) ||
                    (currentZoomLevel <= maxZoomLevel && previousZoomLevel > maxZoomLevel) {
                    // Refresh annotations
                    guard let annotations = mapView?.annotations else { return }
                    mapView?.removeAnnotations(annotations)
                    mapView?.addAnnotations(annotations)
                }
            }
        }
        
        // MARK: - Interface
        
        var viewModel: ViewModel
        weak var mapView: MKMapView?
        
        // MARK: - Initialization
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        // MARK: - Delegate Methods
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let customAnnotation = annotation as? CustomMapAnnotation {
                let annotationView = configureCustomAnnotationView(for: customAnnotation, in: mapView)
                
                if let currentZoomLevel = currentZoomLevel, currentZoomLevel <= maxZoomLevel {
                    annotationView?.clusteringIdentifier = nil
                } else {
                    annotationView?.clusteringIdentifier = "clusterIdentifier"
                }
                
                return annotationView
            } else if let cluster = annotation as? MKClusterAnnotation {
                return configureClusterView(for: cluster, in: mapView)
            }
            return nil
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
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomWidth = mapView.visibleMapRect.size.width
            let zoomLevel = Double(log2(zoomWidth))
            currentZoomLevel = zoomLevel
        }
        
        // MARK: - Private Helpers
        
        private func configureClusterView(for cluster: MKClusterAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
            let identifier = "ClusterAnnotationView"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if clusterView == nil {
                clusterView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
            }
            
            if let firstAnnotation = cluster.memberAnnotations.first as? CustomMapAnnotation {
                clusterView?.markerTintColor = firstAnnotation.clusterColor
            } else {
                clusterView?.markerTintColor = .gray
            }
            
            clusterView?.canShowCallout = false
            clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
            clusterView?.titleVisibility = .hidden
            clusterView?.subtitleVisibility = .hidden
            
            return clusterView
        }
        
        private func configureCustomAnnotationView(for annotation: CustomMapAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
            let identifier = "CustomAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            if let icon = annotation.icon {
                annotationView?.image = icon
                annotationView?.bounds.size = icon.size
                annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            }
            
            annotationView?.clusteringIdentifier = annotation.clusterIdentifier
            return annotationView
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
