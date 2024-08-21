//
//  MapView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.08.2024.
//

import SwiftUI

struct MapView<ViewModel: MapViewModeling>: View {
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        StatusBarContainerView(
            viewModel: self.viewModel.settingsViewModel,
            spacing: MapViewConstants.topPadding
        ) {
            MapViewComponent(viewModel: self.viewModel)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        )
    }
}

enum MapViewConstants {
    static let topPadding: CGFloat = 8
}
