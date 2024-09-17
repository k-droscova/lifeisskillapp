//
//  RankView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import SwiftUI

struct RankView<ViewModel: RankViewModeling>: View {
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
                topLeftView: userNameText,
                spacing: RankViewConstants.imageBottomPadding
            ) {
                ScrollView {
                    rankImageView
                    rankingsList
                        .padding(.horizontal, RankViewConstants.horizontalPadding)
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
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
    private var userNameText: some View {
        Text(viewModel.username)
            .headline3
    }
    
    private var rankImageView: some View {
        Image(CustomImages.Screens.rank.fullPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: RankViewConstants.imageHeight)
            .padding(.bottom, RankViewConstants.imageBottomPadding)
    }
    
    private var rankingsList: some View {
        LazyVStack(spacing: RankViewConstants.spacing) {
            ForEach(viewModel.categoryRankings) { ranking in
                RankListItem(
                    ranking: ranking,
                    largestRank: viewModel.categoryRankings.count
                )
            }
        }
    }
}

struct RankListItem: View {
    let ranking: Ranking
    let largestRank: Int // Precomputed largest rank
    
    var body: some View {
        ListCard {
            HStack(alignment: .center, spacing: RankListItemConstants.spacing) {
                // Rank number
                Text("\(ranking.rank).")
                    .headline2
                    .foregroundColor(.black)
                    .frame(width: getWidthForLargestRank(), alignment: .center)
                    .padding(.leading, RankListItemConstants.leadingPadding)
                
                // User gender icon
                Image(ranking.gender.icon)
                    .resizable()
                    .squareFrame(size: RankListItemConstants.iconSize)
                    //.padding(.horizontal)
                
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
    
    private func getWidthForLargestRank() -> CGFloat {
        let largestRankText = "\(largestRank)."
        let font = AssetsFontFamily.Roboto.medium(size: 20) // Matching the headline3 font size
        let attributes = [NSAttributedString.Key.font: font]
        let size = (largestRankText as NSString).size(withAttributes: attributes)
        return size.width + RankListItemConstants.rankWidth
    }
    
    private enum RankListItemConstants {
        static let spacing: CGFloat = 0
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
    static let horizontalPadding: CGFloat = 10
    static let topPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 30
    static let imageHeight: CGFloat = 200
    static let imageBottomPadding: CGFloat = 20
}

struct RankListView: View {
    let maxRank = 10000
    let rankings = MockData.generateRankings(count: 10000)
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: RankViewConstants.spacing) {
                ForEach(rankings) { ranking in
                    RankListItem(
                        ranking: ranking,
                        largestRank: maxRank)
                }
            }
        }
    }
}

// Preview provider for RankListView
struct RankListView_Previews: PreviewProvider {
    static var previews: some View {
        RankListView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
