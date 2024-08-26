//
//  PointsView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import SwiftUI

struct PointsView<ViewModel: PointsViewModeling>: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        StatusBarContainerView(
            viewModel: self.viewModel.settingsViewModel,
            spacing: 0
        ) {
            CategorySelectorContainerView(
                viewModel: self.viewModel.csViewModel,
                topLeftView: buttonsView,
                spacing: PointsViewConstants.vStackSpacing
            ) {
                if viewModel.isMapButtonPressed {
                    mapView
                }
                else {
                    listView
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear() {
            viewModel.onDisappear()
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

private extension PointsView {
    
    private var listView: some View {
        Group {
            userInfoView
            
            PointsListView(
                points: viewModel.categoryPoints
            ) { point in
                viewModel.showPointOnMap(point: point)
            }
        }
    }
    
    private var mapView: some View {
        MapViewComponent(viewModel: viewModel)
    }
    
    private var buttonsView: some View {
        UserPointsTopLeftButtonsView(
            isMapShown: $viewModel.isMapButtonPressed,
            imageSize: PointsViewConstants.topButtonSize,
            buttonNotPressed: Color.black,
            buttonPressed: Color.colorLisBlue,
            mapButtonAction: viewModel.mapButtonPressed,
            listButtonAction: viewModel.listButtonPressed
        )
    }
    
    private var userInfoView: some View {
        VStack {
            Image(viewModel.userGender.icon)
                .resizable()
                .squareFrame(size: PointsViewConstants.imageSize)
                .clipShape(Circle())
            
            HStack(spacing: PointsViewConstants.horizontalPadding) {
                Text("\(viewModel.username):")
                    .headline3
                Text("\(viewModel.totalPoints)")
                    .subheadline
            }
            .padding(.horizontal)
        }
    }
}

enum PointsViewConstants {
    static let vStackSpacing: CGFloat = 16
    static let topButtonSize: CGFloat = 20
    static let imageSize: CGFloat = 200
    static let horizontalPadding: CGFloat = 4
}
