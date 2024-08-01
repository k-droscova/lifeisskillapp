//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModeling
    
    init(viewModel: HomeViewModeling) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            topBarView
            ScrollView {
                VStack {
                    imageView
                    instructionsView
                    // TODO: change button colors to match LiS
                    buttonsView
                }
            }
        }
    }
    
    private var topBarView: some View {
        HStack {
            Text(viewModel.username)
                .padding()
                .headline3
            Spacer()
            // TODO: ask Martin if this should be implemented since the POST request for scanned point does not specify user category and hence it can be confusing for user (why is this here? can I choose which category this scanned point is going to count towards?)
            // MARK: - if this is going to be kept, then homeviewmodel will need to provide the usercategory list for the drowdownmenu through property
            DropdownMenu()
                .subheadline
                .foregroundColor(.secondary)
        }
    }
    
    private var imageView: some View {
        Image(CustomImages.home.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .padding()
    }
    
    private var instructionsView: some View {
        Text("home.description")
            .body1Regular
            .padding(.horizontal, 34)
            .padding()
    }
    
    private var buttonsView: some View {
        VStack {
            Button(action: viewModel.loadWithNFC) {
                Text("home.nfc.button")
            }
            .homeButtonStyle(background: .pink, text: .white)
            .padding()
            
            Button(action: viewModel.loadWithQRCode) {
                Text("home.qr.button")
            }
            .homeButtonStyle(background: .green, text: .white)
            .padding()
            
            Button(action: viewModel.loadFromCamera) {
                Text("home.camera.button")
            }
            .homeButtonStyle(background: .yellow, text: .black)
            .padding()
            
            Button(action: viewModel.showOnboarding) {
                Text("home.button.how")
            }
            .homeButtonStyle(background: .clear, text: .secondary)
            .padding()
        }
    }
}

class MockHomeViewModel: BaseClass, HomeViewModeling {
    var username: String = "Test"
    
    func loadWithNFC() {
        print("I was tapped: loadWithNFC")
    }
    
    func loadWithQRCode() {
        print("I was tapped: loadWithQRCode")
    }
    
    func loadFromCamera() {
        print("I was tapped: loadFromCamera")
    }
    
    func dismissCamera() {
        print("I was tapped: dismissCamera")
    }
    
    func showOnboarding() {
        print("I was tapped: showOnboarding")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: MockHomeViewModel())
    }
}
