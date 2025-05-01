//
//  LocationStatusBarView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import SwiftUI

struct LocationStatusBarView<ViewModel: LocationStatusBarViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            locationText
                .frame(width: LocationStatusBarViewConstants.locationTextWidth, alignment: .leading)
            Spacer()
            statusIndicators
            Spacer()
            appVersionText
        }
        .foregroundStyle(CustomColors.LocationStatusBar.foreground.color)
        .locationCaption
        .padding([.leading, .trailing])
    }
    
    @ViewBuilder
    private var locationText: some View {
        if let location = viewModel.userLocation, viewModel.isGpsOk {
            Text(location.description)
        } else {
            Text("locationStatusBar.waiting")
        }
    }
    
    private var statusIndicators: some View {
        HStack(spacing: 16) {
            StatusView(
                status: $viewModel.isOnline,
                textOn: "ONLINE",
                textOff: "OFFLINE",
                colorOn: CustomColors.LocationStatusBar.statusOn.color,
                colorOff: CustomColors.LocationStatusBar.statusOff.color
            )
            StatusView(
                status: $viewModel.isGpsOk,
                textOn: "GPS OK",
                textOff: "GPS OFF",
                colorOn: CustomColors.LocationStatusBar.statusOn.color,
                colorOff: CustomColors.LocationStatusBar.statusOff.color
            )
        }
    }
    
    private var appVersionText: some View {
        Text(viewModel.appVersion)
    }
}

struct LocationStatusBarViewConstants {
    static let locationTextWidth: CGFloat = 180
}
