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
    var pointType: PointType
    var id: String
    
    init(point: GenericPoint) {
        coordinate = CLLocationCoordinate2D(latitude: point.pointLat, longitude: point.pointLng)
        title = nil
        subtitle = nil
        pointType = point.pointType
        id = point.id
    }
    
    var icon: UIImage? {
        UIImage(named: pointType.iconName)
    }
    
    var clusterColor: UIColor {
        UIColor(pointType.color)
    }
    
    // Clustering identifier based on the icon name or point type
    var clusterIdentifier: String {
        pointType.rawValue.description // This ensures points with the same icon are clustered together
    }
}
