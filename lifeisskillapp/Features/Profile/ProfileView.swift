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
        .onTapGesture {
            hideKeyboard()
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
        }
    }
    
    private var parentEmailActivationView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.colorLisRose)
                .frame(height: 220)
            
            VStack(alignment: .leading, spacing: 16) {
                parentEmailPromptView
                parentEmailFormView
            }
            .frame(maxHeight: 200)
            .foregroundStyle(.colorLisWhite)
            .padding(.horizontal, 12)
        }
    }
    
    private var parentEmailPromptView: some View {
        VStack {
            HStack(alignment: .center) {
                SFSSymbols.warning.image
                    .resizable()
                    .squareFrame(size: 24)
                Spacer()
                Text("profile.parent_email.prompt")
                    .multilineTextAlignment(.center)
                Spacer()
                SFSSymbols.warning.image
                    .resizable()
                    .squareFrame(size: 24)
            }
            .headline2
            Text("profile.parent_email.button_prompt")
                .subheadlineBold
                .padding(.horizontal, 4)
        }
    }
    
    private var parentEmailFormView: some View {
        HStack(alignment: .top) {
            CustomTextField(
                placeholder: "profile.parent_email.textfield",
                text: $viewModel.parentActivationEmail,
                isSecure: false,
                showsValidationMessage: true,
                validationTextColor: .colorLisWhite,
                validationMessage: viewModel.guardianEmailValidationState.validationMessage
            ) {
                Button(action: viewModel.sendParentActivationEmail) {
                    SFSSymbols.send.image
                        .resizable()
                        .squareFrame(size: 20)
                        .foregroundStyle(viewModel.isSendActivationButtonEnabled ? .colorLisBlue : .colorLisDarkGrey)
                }
                .disabled(!viewModel.isSendActivationButtonEnabled)
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
            if viewModel.requiresParentEmailActivation {
                parentEmailActivationView
                    .padding(.horizontal, ProfileViewConstants.emailActivationHorizontalPadding)
            }
            userDetailInfo
                .frame(maxWidth: ProfileViewConstants.maxDetailFrameWidth)
                .padding(.horizontal, ProfileViewConstants.userInfoHorizontalPadding)
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
        EnablingButton(
            action: viewModel.startRegistration,
            text: "profile.register.button",
            enabledColorBackground: ProfileViewConstants.Colors.registerButtonBackground,
            enabledColorText: ProfileViewConstants.Colors.registerButtonForeground,
            isEnabled: true
        )
        .headline3
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
    static let maxDetailFrameWidth: CGFloat = 600
    static let contentViewVerticalSpacing: CGFloat = 16
    static let minSpaceAboveRegisterButton: CGFloat = 64
    static let minSpaceAboveInviteButton: CGFloat = 32
    static let backButtonSpacingBetweenButtonAndText: CGFloat = 12
    static let backButtonLeadingPadding: CGFloat = 12
    static let backButtonTopPadding: CGFloat = 12
    static let userInfoVStackSpacing: CGFloat = 32
    static let userDetailsVerticalSpacing: CGFloat = 12
    static let userInfoHorizontalPadding: CGFloat = 32
    static let emailActivationHorizontalPadding: CGFloat = 12
    static let iconSize: CGFloat = UIScreen.main.bounds.height * 0.25
    
    enum Colors {
        static let backButtonForeground = Color.colorLisBlue
        static let registerButtonBackground = Color.colorLisRose
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
