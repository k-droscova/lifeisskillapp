//
//  ProfileView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import SwiftUI

struct ProfileView<ViewModel: ProfileViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        StatusBarContainerView(
            viewModel: self.viewModel.settingsViewModel,
            spacing: ProfileViewConstants.backButtonTopPadding
        ) {
            contentView
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

private extension ProfileView {
    private var contentView: some View {
        VStack(spacing: ProfileViewConstants.contentViewVerticalSpacing) {
            backButton
            ScrollView {
                userInfoView
                Spacer(minLength: ProfileViewConstants.minSpaceAboveRegisterButton)
                if !viewModel.isFullyRegistered {
                    registerButton
                }
                Spacer(minLength: ProfileViewConstants.minSpaceAboveInviteButton)
                inviteFriendButton
            }
        }
    }
    
    private var backButton: some View {
        HStack {
            Button(action: viewModel.navigateBack) {
                HStack(alignment: .center, spacing: ProfileViewConstants.backButtonSpacingBetweenButtonAndText) {
                    SFSSymbols.navigationBack.image
                    Text("profile.back.button")
                        .subheadline
                }
            }
            Spacer()
        }
        .foregroundStyle(ProfileViewConstants.Colors.backButtonForeground)
        .padding(.leading, ProfileViewConstants.backButtonLeadingPadding)
    }
    
    private var userInfoView: some View {
        VStack(spacing: ProfileViewConstants.userInfoVStackSpacing) {
            Image(viewModel.userGender.icon)
                .resizable()
                .squareFrame(size: ProfileViewConstants.iconSize)
                .clipShape(Circle())
            Text("\(viewModel.username)")
                .headline3
            VStack(alignment: .leading, spacing: ProfileViewConstants.userDetailsVerticalSpacing) {
                HStack {
                    Text("profile.email")
                        .subheadlineBold
                    Spacer()
                    Text("\(viewModel.email)")
                        .body1Regular
                }
                
                HStack {
                    Text("profile.main_category")
                        .subheadlineBold
                    Spacer()
                    Text("\(viewModel.mainCategory)")
                        .body1Regular
                }
            }
        }
        .padding(.horizontal, ProfileViewConstants.userInfoHorizontalPadding)
    }
    
    private var registerButton: some View {
        HomeButton(
            action: viewModel.startRegistration,
            background: ProfileViewConstants.Colors.registerButtonBackground,
            foregroundColor: ProfileViewConstants.Colors.registerButtonForeground
        ) {
            Text("profile.register.button")
        }
    }
    
    private var inviteFriendButton: some View {
        Button(action: viewModel.inviteFriend) {
            Text("profile.invite.button")
        }
        .foregroundStyle(ProfileViewConstants.Colors.inviteButton)
        .subheadline
    }
}

enum ProfileViewConstants {
    static let contentViewVerticalSpacing: CGFloat = 16
    static let minSpaceAboveRegisterButton: CGFloat = 64
    static let minSpaceAboveInviteButton: CGFloat = 32
    static let backButtonSpacingBetweenButtonAndText: CGFloat = 12
    static let backButtonLeadingPadding: CGFloat = 12
    static let backButtonTopPadding: CGFloat = 12
    static let userInfoVStackSpacing: CGFloat = 32
    static let userDetailsVerticalSpacing: CGFloat = 12
    static let userInfoHorizontalPadding: CGFloat = 32
    static let iconSize: CGFloat = 200
    
    enum Colors {
        static let backButtonForeground = Color.colorLisBlue
        static let registerButtonBackground = Color.colorLisBlue
        static let registerButtonForeground = Color.white
        static let inviteButton = Color.colorLisBlue
    }
}
