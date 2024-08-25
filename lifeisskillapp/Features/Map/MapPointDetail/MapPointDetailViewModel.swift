//
//  MapDetailViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.08.2024.
//

import Foundation
import SwiftUI

protocol MapPointDetailViewModeling: ObservableObject {
    var pointName: String { get }
    var pointValueText: String { get }
    var sponsorText: String { get }
    var detailURL: URL? { get }
    var hasDetail: Bool { get }
    var icon: Image { get }
}

final class MapPointDetailViewModel: ObservableObject, MapPointDetailViewModeling {
    
    // MARK: - Private Properties
    
    private let point: GenericPoint
    
    // MARK: - Public Properties
    
    var pointName: String { point.pointName }
    var pointValueText: String {
        String(format: NSLocalizedString("map.detail.value", comment: ""), String(point.pointValue))
    }
    var sponsorText: String {
        String(format: NSLocalizedString("map.detail.sponsor", comment: ""), String(point.sponsorId))
    }
    var detailURL: URL? {
        #if DEBUG
        let urlString = APIUrl.detailUrlDebug + "\(point.id)"
        #else
        let urlString = APIUrl.detailUrl + "\(point.id)"
        #endif
        return URL(string: urlString)
    }
    var hasDetail: Bool { point.hasDetail }
    var icon: Image { point.pointType.icon }
    
    // MARK: - Initialization
    
    init(point: GenericPoint) {
        self.point = point
    }
}
