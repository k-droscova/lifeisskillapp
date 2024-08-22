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
    init(point: GenericPoint) {
        self.viewModel = MapPointDetailViewModel(point: point)
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
            
            // TODO: need to implement fetching of images once I have permanent storage -> will need to redo generic point model to have optional image attribute and store it as data or something similar
            Text(viewModel.sponsorText)
                .body2Regular
            
            HStack {
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
