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
                    Text("settings.logout".localized)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.printUserCategoryData,
                label: {
                    Text("User Category Data".localized)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.printUserPointData,
                label: {
                    Text("User Point Data".localized)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.printGenericPointData,
                label: {
                    Text("Generic Point Data".localized)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.blue)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
        }
        .onAppear(perform: {
            viewModel.fetchData()
        })
    }
}

