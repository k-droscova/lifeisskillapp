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
                        .padding(.bottom, RankViewConstants.scrollViewBottomPadding)
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
    
    private var toggleListModeButton: some View {
        HStack {
            Spacer()
            Text("ranking.listMode.toggleButton")
                .subheadlineBold
            Spacer()
            Toggle("ranking.listMode.toggleButton", isOn: $viewModel.isListComplete)
                .labelsHidden() // Hide the default label for the toggle
                .toggleStyle(SwitchToggleStyle(tint: .colorLisBlue))
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var rankImageView: some View {
        Image(CustomImages.Screens.rank.fullPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: RankViewConstants.imageHeight)
            .padding(.bottom, RankViewConstants.imageBottomPadding)
    }
    
    private var rankingsList: some View {
        Group {
            if viewModel.isSeparationModeEnabled {
                VStack(alignment: .center, spacing: RankViewConstants.separatedListToggleListVerticalSpacing) {
                    toggleListModeButton
                    if viewModel.isListComplete {
                        wholeList
                    }
                    else {
                        separatedList
                    }
                }
            }
            else {
                wholeList
            }
        }
    }
    
    private var separatedList: some View {
        LazyVStack {
            // Top Rankings (first 20)
            ForEach(viewModel.topRankings) { ranking in
                RankListItem(
                    ranking: ranking,
                    largestRank: viewModel.totalRankings,
                    isUserRank: ranking.rank == viewModel.userRank
                )
            }
            
            // Middle Rankings (if available)
            if let middleRankings = viewModel.middleRankings {
                LazyVStack {
                    threeDots
                    
                    ForEach(middleRankings) { ranking in
                        RankListItem(
                            ranking: ranking,
                            largestRank: viewModel.totalRankings,
                            isUserRank: ranking.rank == viewModel.userRank
                        )
                    }
                }
            }
            
            threeDots
            
            // Bottom Rankings (last 10)
            ForEach(viewModel.bottomRankings) { ranking in
                RankListItem(
                    ranking: ranking,
                    largestRank: viewModel.totalRankings,
                    isUserRank: ranking.rank == viewModel.userRank
                )
            }
        }
    }
    
    private var wholeList: some View {
        LazyVStack {
            ForEach(viewModel.categoryRankings) { ranking in
                RankListItem(
                    ranking: ranking,
                    largestRank: viewModel.totalRankings,
                    isUserRank: ranking.rank == viewModel.userRank
                )
            }
        }
    }
    
    private var threeDots: some View {
        SFSSymbols.more.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .squareFrame(size: 60)
            .scaleEffect(0.5)
    }
}

struct RankListItem: View {
    let ranking: Ranking
    let largestRank: Int // To calculate the min width for rank number frame
    let isUserRank: Bool // Flag to determine if this is the user's rank
    
    private var foregroundColor: Color {
        isUserRank ? CustomColors.ListCard.foregroundUser.color : CustomColors.ListCard.foreground.color
    }
    
    private var backgroundColor: Color {
        isUserRank ?  CustomColors.ListCard.backgroundUser.color : CustomColors.ListCard.background.color
    }
    
    init(
        ranking: Ranking,
        largestRank: Int,
        isUserRank: Bool = false
    ) {
        self.ranking = ranking
        self.largestRank = largestRank
        self.isUserRank = isUserRank
    }
    
    var body: some View {
        ListCard(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ) {
            content
                .padding(.vertical, RankListItemConstants.innerPadding)
        }
    }
    
    private var content: some View {
        HStack(alignment: .center, spacing: RankListItemConstants.spacing) {
            // Rank number
            Text("\(ranking.rank).")
                .headline2
                .frame(width: getWidthForLargestRank(), alignment: .center)
                .padding(.leading, RankListItemConstants.leadingPadding)
            
            // User gender icon
            Image(ranking.gender.icon)
                .resizable()
                .squareFrame(size: RankListItemConstants.iconSize)
                .padding(.horizontal, RankListItemConstants.iconHorizontalPadding)
            
            // VStack with username and points
            VStack(alignment: .leading, spacing: RankListItemConstants.usernamePointVerticalSpacing) {
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
    
    // Helper to calculate the widest ranking number to provide sufficient frame
    private func getWidthForLargestRank() -> CGFloat {
        let largestRankText = "\(largestRank)."
        let font = AssetsFontFamily.Roboto.medium(size: 20) // Matching the headline3 font size
        let attributes = [NSAttributedString.Key.font: font]
        let size = (largestRankText as NSString).size(withAttributes: attributes)
        return size.width + RankListItemConstants.rankWidth
    }
    
    private enum RankListItemConstants {
        static let innerPadding: CGFloat = 12
        static let spacing: CGFloat = 0
        static let usernamePointVerticalSpacing: CGFloat = 4
        static let iconSize: CGFloat = 48
        static let iconHorizontalPadding: CGFloat = 8
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
    static let separatedListToggleListVerticalSpacing: CGFloat = 16
    static let topPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 30
    static let imageHeight: CGFloat = 200
    static let imageBottomPadding: CGFloat = 20
    static let scrollViewBottomPadding: CGFloat = 16
}
