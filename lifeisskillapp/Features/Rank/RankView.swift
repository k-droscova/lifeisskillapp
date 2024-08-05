//
//  RankView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import SwiftUI

struct RankView<ViewModel: RankViewModeling>: View {
    @StateObject var viewModel: ViewModel
    private let categorySelectorVC: UIViewController
    
    init(viewModel: ViewModel, categorySelectorVC: UIViewController) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.categorySelectorVC = categorySelectorVC
    }
    
    var body: some View {
        CategorySelectorContainerView(
            categorySelectorVC: categorySelectorVC,
            spacing: RankViewConstants.imageBottomPadding
        ) {
            rankImageView
            
            rankingsList
                .padding(.horizontal, RankViewConstants.horizontalPadding)
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
}

private extension RankView {
    
    private var rankImageView: some View {
        Image(CustomImages.Screens.rank.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: RankViewConstants.imageHeight)
            .padding(.bottom, RankViewConstants.imageBottomPadding)
    }
    
    private var rankingsList: some View {
        ScrollView {
            LazyVStack(spacing: RankViewConstants.spacing) {
                ForEach(viewModel.categoryRankings) { ranking in
                    RankListItem(ranking: ranking)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct RankListItem: View {
    let ranking: Ranking
    
    var body: some View {
        ListCard {
            HStack(spacing: RankListItemConstants.spacing) {
                // Rank number
                Text("\(ranking.rank).")
                    .headline2
                    .foregroundColor(.primary)
                    .frame(width: RankListItemConstants.rankWidth, alignment: .leading)
                    .padding(.leading, RankListItemConstants.leadingPadding)
                
                // User gender icon
                Image(ranking.gender.icon)
                    .resizable()
                    .squareFrame(size: RankListItemConstants.iconSize)
                
                // VStack with username and points
                VStack(alignment: .leading, spacing: 4) {
                    Text(ranking.username)
                        .headline3
                    Text("\(ranking.points) pts")
                        .body1Regular
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Trophy image
                if let trophyImage = ranking.trophyImage {
                    Image(trophyImage)
                        .resizable()
                        .squareFrame(size: RankListItemConstants.trophyImageSize)
                        .padding(.trailing, RankListItemConstants.trailingPadding)
                }
            }
        }
    }
    
    private enum RankListItemConstants {
        static let spacing: CGFloat = 4
        static let iconSize: CGFloat = 48
        static let trophyImageSize: CGFloat = 48
        static let leadingPadding: CGFloat = 16
        static let trailingPadding: CGFloat = 16
        static let rankWidth: CGFloat = 30
    }
}

// NOTE: constants are not in extension because static properties are not allowed in generic types

enum RankViewConstants {
    static let spacing: CGFloat = 16
    static let horizontalPadding: CGFloat = 30
    static let topPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 30
    static let imageHeight: CGFloat = 200
    static let imageBottomPadding: CGFloat = 20
}

struct RankView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MockRankViewModel()
        RankView(viewModel: mockViewModel, categorySelectorVC:
                    CategorySelectorView(viewModel: MockCategorySelectorViewModel()).hosting())
    }
}

// Mock ViewModel for preview
class MockRankViewModel: BaseClass, RankViewModeling, ObservableObject {
    @Published var categoryRankings: [Ranking] = [
        Ranking(id: "1", rank: 1, username: "User1", points: 100, gender: .male),
        Ranking(id: "2", rank: 2, username: "User2", points: 90, gender: .female),
        Ranking(id: "3", rank: 3, username: "User3", points: 80, gender: .male)
    ]
    
    var isLoading: Bool = false
    
    func onAppear() {
        // Mock onAppear behavior
        print("Mock onAppear")
    }
}
