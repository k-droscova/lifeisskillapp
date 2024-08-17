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
    @State private var selectedPoint: Point?
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.points) { point in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: point.location.latitude, longitude: point.location.longitude)) {
                    CustomMapPin(point: point, isSelected: point.id == selectedPoint?.id)
                        .onTapGesture {
                            selectedPoint = point
                            viewModel.onPointSelected(point)
                        }
                }
            }
            if let selectedPoint = selectedPoint {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(selectedPoint.name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}
