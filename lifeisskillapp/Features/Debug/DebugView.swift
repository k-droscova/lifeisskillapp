//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct DebugView: View {
    @State var viewModel: DebugViewModeling
    
    var body: some View {
        contentView
            .padding(30)
    }
    
    var contentView: some View {
        VStack {
            Button(action: viewModel.logout) {
                Text("settings.logout")
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserCategoryData) {
                Text("User Category Data")
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserPointData) {
                Text("User Point Data")
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printGenericPointData) {
                Text("Generic Point Data")
            }
            .logoutButtonStyle()
            
            Spacer()
            
            Button(action: viewModel.printUserRankData) {
                Text("User Rank Data")
            }
            .logoutButtonStyle()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

