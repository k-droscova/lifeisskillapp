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
            
            Spacer()
            
            VStack {
                Text("Home screen")
                
                Divider()
                
                Text("To do")
                .padding(.top, 20)
                
                Divider()
            }
            
        }
    }
}

