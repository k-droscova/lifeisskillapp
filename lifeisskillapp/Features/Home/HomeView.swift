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
            Button(
                action: viewModel.logout,
                label: {
                    Text(LocalizedStringKey("settings.logout"))
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.fetchUserCategoryData,
                label: {
                    Text("User Category Data")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.fetchUserPointData,
                label: {
                    Text("User Point Data")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
        }
    }
}

