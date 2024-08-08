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
        .onAppear {
            viewModel.onAppear()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        )
    }
    
    private var buttonsView: some View {
        UserPointsTopLeftButtonsView(
            isMapShown: $viewModel.isMapButtonPressed,
            imageSize: PointsViewConstants.topButtonSize,
            buttonNotPressed: Color.black,
            buttonPressed: Color.colorLisBlue,            mapButtonAction: {
                viewModel.mapButtonPressed()
            },
            listButtonAction: {
                viewModel.listButtonPressed()
            }
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

class MockPointsViewModel: BaseClass, PointsViewModeling, ObservableObject {
    @Published var csViewModel: MockCategorySelectorViewModel = MockCategorySelectorViewModel()
    
    @Published var isLoading: Bool = false
    @Published var isMapButtonPressed: Bool = false
    @Published var username: String = "TestUser"
    @Published var userGender: UserGender = .male
    @Published var totalPoints: Int = 0
    @Published var categoryPoints: [Point] = []
    
    func onAppear() {
        // Simulate network loading
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoading = false
            self?.totalPoints = 100
            self?.categoryPoints = [
                Point(id: "1", name: "Point 1", value: 10, type: .environment, doesPointCount: true),
                Point(id: "2", name: "Point 2", value: 20, type: .culture, doesPointCount: false)
            ]
        }
    }
    
    
    func mapButtonPressed() {
        // Mock map button pressed behavior
        print("Mock map button pressed")
    }
    
    func listButtonPressed() {
        // Mock list button pressed behavior
        print("Mock list button pressed")
    }
    
    func showPointOnMap(point: Point) {
        // Mock show point on map behavior
        print("Mock showing map for point: \(point.name)")
    }
}

// Example usage with mock data
struct PointsView_Previews: PreviewProvider {
    static var previews: some View {
        PointsView(viewModel: MockPointsViewModel())
    }
}
