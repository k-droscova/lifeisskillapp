//
//  MapPointDetailView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.08.2024.
//

import SwiftUI

struct MapPointDetailView: View {
    @ObservedObject private var viewModel: MapPointDetailViewModel
    
    // Custom initializer that accepts a GenericPoint
    init(dependencies: MapPointDetailViewModel.Dependencies, point: GenericPoint) {
        self.viewModel = MapPointDetailViewModel(dependencies: dependencies, point: point)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapPointDetailViewConstants.vstackSpacing) {
            HStack {
                viewModel.icon
                Text(viewModel.pointName)
                    .headline3
                Spacer()
            }
            ExDivider(color: Color.black, height: MapPointDetailViewConstants.dividerHeight)
            
            Text(viewModel.pointValueText)
                .body2Regular
            
            Text(viewModel.sponsorText)
                .body2Regular
            
            HStack {
                // TODO: need to fix formatting of the height of the sheet somehow
                if let sponsorImage = viewModel.sponsorImage {
                    sponsorImage
                }
                Spacer()
                if viewModel.hasDetail, let detailURL = viewModel.detailURL {
                    Link(LocalizedStringKey("map.detail"), destination: detailURL)
                        .subheadline
                        .foregroundColor(MapPointDetailViewConstants.Colors.linkColor)
                        .padding(.top, MapPointDetailViewConstants.linkTopPadding)
                }
            }
        }
        .padding(MapPointDetailViewConstants.viewPadding)
        .background(MapPointDetailViewConstants.Colors.backgroundColor)
        .onAppear {
            viewModel.onAppear() 
        }
    }
}

enum MapPointDetailViewConstants {
    static let vstackSpacing: CGFloat = 8
    static let dividerHeight: CGFloat = 1
    static let linkTopPadding: CGFloat = 10
    static let viewPadding: CGFloat = 16
    
    enum Colors {
        static let linkColor: Color = .colorLisBlue
        static let backgroundColor: Color = .white
    }
}
