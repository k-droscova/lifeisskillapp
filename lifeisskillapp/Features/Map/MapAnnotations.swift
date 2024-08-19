//
//  MapAnnotations.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.08.2024.
//

import Foundation
import MapKit

class CustomMapAnnotation: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var icon: UIImage?
    var id: String
    
    init(point: GenericPoint) {
        self.coordinate = CLLocationCoordinate2D(latitude: point.pointLat, longitude: point.pointLng)
        self.title = point.pointName
        self.subtitle = nil 
        self.icon = UIImage(named: point.pointType.iconName)
        self.id = point.id
    }
}
