//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModeling

    var body: some View {
        VStack {
            Button(action: viewModel.loadWithNFC) {
                Text("home.nfc.button")
            }
            .loginButtonStyle()

            Button(action: viewModel.loadWithQRCode) {
                Text("home.qr.button")
            }
            .loginButtonStyle()

            Button(action: viewModel.loadFromPhoto) {
                Text("home.photo.button")
            }
            .loginButtonStyle()
        }
    }
}
