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
    var sponsorImage: Image? { get }
    var detailURL: URL? { get }
    var hasDetail: Bool { get }
    var icon: Image { get }
    
    func onAppear()
}

final class MapPointDetailViewModel: ObservableObject, MapPointDetailViewModeling {
    typealias Dependencies = HasGenericPointManager & HasLoggers
    
    // MARK: - Private Properties
    
    private let point: GenericPoint
    private let genericPointManager: any GenericPointManaging
    private let logger: LoggerServicing
    
    // MARK: - Public Properties
    
    var pointName: String { point.pointName }
    var pointValueText: String {
        String(format: NSLocalizedString("map.detail.value", comment: ""), String(point.pointValue))
    }
    @Published var sponsorImage: Image?
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
    
    init(dependencies: Dependencies, point: GenericPoint) {
        self.genericPointManager = dependencies.genericPointManager
        self.logger = dependencies.logger
        self.point = point
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                if let imageData = try await self.genericPointManager.sponsorImage(for: self.point.sponsorId, width: 200, height: 150), 
                    let image = UIImage(data: imageData) {
                    self.sponsorImage = Image(uiImage: image)
                }
            } catch {
                self.logger.log(message: "Unable to fetch image for \(self.point.pointName) with sponsor Id: \(self.point.sponsorId)")
            }
        }
    }
}
