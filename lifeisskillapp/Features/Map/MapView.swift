//
//  MapView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import SwiftUI
import MapKit

struct MapView<ViewModel: MapViewModeling>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.points
        ) { point in
            MapAnnotation(coordinate: point.coordinate) {
                point.pointType.icon
                .onTapGesture {
                    viewModel.onPointTapped(point)
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
