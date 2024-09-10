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
                if viewModel.requiresToCompleteRegistration {
                    registerButton
                }
                inviteFriendButton
            }
            .padding(.horizontal, ProfileViewConstants.userInfoHorizontalPadding)
        }
    }
    
    private var parentEmailActivationView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.colorLisRose) // Pink background
                .frame(height: 200) // Adjust the height as needed
            
            VStack(alignment: .leading, spacing: 16) {
                parentEmailPromptView
                    .padding(.horizontal, 4)
                parentEmailFormView
            }
            .foregroundStyle(.colorLisWhite)
            .padding(.horizontal, 16)
        }
    }
    
    private var parentEmailPromptView: some View {
        VStack {
            HStack {
                SFSSymbols.warning.image
                    .resizable()
                    .squareFrame(size: 24)
                Spacer()
                Text("profile.parent_email.prompt")
                    .headline3
                Spacer()
                SFSSymbols.warning.image
                    .resizable()
                    .squareFrame(size: 24)
            }
            Text("profile.parent_email.button_prompt")
                .subheadlineBold
        }
    }
    
    private var parentEmailFormView: some View {
        HStack(alignment: .center) {
            CustomTextField(
                placeholder: "profile.parent_email.textfield",
                text: $viewModel.parentEmail,
                isSecure: false,
                showsValidationMessage: true,
                validationMessage: viewModel.guardianEmailValidationState.validationMessage
            )
            
            Spacer(minLength: 16)
            
            Button(action: viewModel.sendParentActivationEmail) {
                SFSSymbols.virtual.image
                    .resizable()
                    .squareFrame(size: 32)
                    .foregroundStyle(.colorLisWhite)
            }
            .disabled(!viewModel.isSendActivationButtonEnabled)
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
            if viewModel.requiresParentEmailActivation {
                parentEmailActivationView
            }
            userDetailInfo
        }
    }
    
    private var userDetailInfo: some View {
        VStack(alignment: .leading, spacing: ProfileViewConstants.userDetailsVerticalSpacing) {
            ProfileDetailRow(title: "profile.email", value: viewModel.email)
            if !viewModel.requiresToCompleteRegistration {
                additionalUserInfo
            }
        }
    }
    
    private var additionalUserInfo: some View {
        VStack(alignment: .leading, spacing: ProfileViewConstants.userDetailsVerticalSpacing) {
            ProfileDetailRow(title: "profile.main_category", value: viewModel.mainCategory)
            ProfileDetailRow(title: "profile.name", value: viewModel.name)
            ProfileDetailRow(title: "profile.phone", value: viewModel.phoneNumber)
            ProfileDetailRow(title: "profile.postal_code", value: viewModel.postalCode)
            ProfileDetailRow(title: "profile.birthday", value: viewModel.birthday)
            ProfileDetailRow(title: "profile.age", value: "\(viewModel.age)")
            
            // Show parent information if the user is a minor
            if viewModel.isMinor {
                parentInfo
            }
        }
    }
    
    private var parentInfo: some View {
        VStack() {
            Text("register.guardian_info")
                .headline3
                .padding(.vertical, 2 * ProfileViewConstants.userDetailsVerticalSpacing)
            VStack(alignment: .leading, spacing: ProfileViewConstants.userDetailsVerticalSpacing) {
                ProfileDetailRow(title: "profile.name", value: viewModel.parentName)
                ProfileDetailRow(title: "profile.email", value: viewModel.parentEmail)
                ProfileDetailRow(title: "profile.phone", value: viewModel.parentPhone)
                ProfileDetailRow(title: "profile.relation", value: viewModel.parentRelation)
            }
        }
    }
    
    private var registerButton: some View {
        HomeButton(
            action: viewModel.startRegistration,
            background: ProfileViewConstants.Colors.registerButtonBackground,
            foregroundColor: ProfileViewConstants.Colors.registerButtonForeground
        ) {
            Text("profile.register.button")
        }
        .padding(.top, ProfileViewConstants.minSpaceAboveRegisterButton)
    }
    
    private var inviteFriendButton: some View {
        Button(action: viewModel.inviteFriend) {
            Text("profile.invite.button")
        }
        .foregroundStyle(ProfileViewConstants.Colors.inviteButton)
        .subheadline
        .padding(.vertical, ProfileViewConstants.minSpaceAboveInviteButton)
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MockProfileViewModel())
            .previewLayout(.sizeThatFits)
    }
}
