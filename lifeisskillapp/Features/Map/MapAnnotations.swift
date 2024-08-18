//
//  MapAnnotations.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.08.2024.
//

import Foundation
import MapKit

protocol MapAnnotationConvertible {
    var coordinate: CLLocationCoordinate2D { get }
    var title: String? { get }
    var subtitle: String? { get }
}

extension GenericPoint: MapAnnotationConvertible {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: pointLat, longitude: pointLng)
    }
    var title: String? { nil }
    var subtitle: String? { nil }
}

class CustomMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(annotation: MapAnnotationConvertible) {
        self.coordinate = annotation.coordinate
        self.title = annotation.title
        self.subtitle = annotation.subtitle
    }
}
