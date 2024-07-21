//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModeling
    
    
    var body: some View {
        contentView
            .padding(30)
    }
    
    var contentView: some View {
        VStack {
            Button(action: viewModel.logout) {
                Text("settings.logout".localized)
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserCategoryData) {
                Text("User Category Data".localized)
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserPointData) {
                Text("User Point Data".localized)
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printGenericPointData) {
                Text("Generic Point Data".localized)
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserRankData) {
                Text("User Rank Data".localized)
            }
            .logoutButtonStyle()
        }
        .onAppear(perform: {
            viewModel.fetchData()
        })
    }
}

