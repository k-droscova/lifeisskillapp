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
                userInfoView
                
                PointsListView(
                    points: viewModel.categoryPoints
                ) { point in
                    viewModel.showPointOnMap(point: point)
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

/*class MockPointsViewModel: BaseClass, PointsViewModeling, ObservableObject {
 var csViewModel: MockCategorySelectorViewModel = MockCategorySelectorViewModel()
 
 var isLoading: Bool = false
 @Published var isMapButtonPressed: Bool = false
 var username: String = "TestUser"
 var userGender: UserGender = .male
 var totalPoints: Int = 0
 var categoryPoints: [Point] = []
 
 func onAppear() {
 // Simulate network loading
 isLoading = true
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
 self?.totalPoints = 100
 self?.categoryPoints = [Point.MockPoint1, Point.MockPoint2]
 self?.isLoading = false
 }
 }
 
 
 func mapButtonPressed() {
 print("Mock map button pressed")
 }
 
 func listButtonPressed() {
 print("Mock list button pressed")
 }
 
 func showPointOnMap(point: Point) {
 print("Mock showing map for point: \(point.name)")
 }
 }
 
 // Example usage with mock data
 struct PointsView_Previews: PreviewProvider {
 static var previews: some View {
 PointsView(viewModel: MockPointsViewModel())
 }
 }
 */
