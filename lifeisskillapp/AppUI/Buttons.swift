//
//  Buttons.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import Foundation
import SwiftUI

// Example Button Views using the new styles
struct CameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SFSSymbols.camera.Image
        }
        .buttonStyle(CameraButtonStyle())
    }
}

struct FlashButton: View {
    let action: () -> Void
    @Binding var flashOn: Bool
    
    var body: some View {
        Button(action: action) {
            flashOn ?
            Image(CustomImages.CornerIcons.flashOn.fullPath)
                .resizable()
                .frame(width: 16, height: 24)
            :
            Image(CustomImages.CornerIcons.flashOff.fullPath)
                .resizable()
                .frame(width: 16, height: 24)
        }
        .buttonStyle(CameraButtonStyle())
    }
}

struct HomeButton: View {
    let action: () -> Void
    let text: Text
    let background: Color
    let textColor: Color
    
    var body: some View {
        Button(action: action) {
            text
        }
        .buttonStyle(HomeButtonStyle(color: background, textColor: textColor))
    }
}

struct EnablingButton: View {
    let action: () -> Void
    let text: Text
    let enabledColorBackground: Color
    let disabledColorBackground: Color
    let enabledColorText: Color
    let disabledColorText: Color
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            text
                .foregroundColor(isEnabled ? enabledColorText : disabledColorText)
                .padding()
                .padding(.horizontal, 20)
                .background(isEnabled ? enabledColorBackground : disabledColorBackground)
                .cornerRadius(20)
        }
        .subheadline
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .disabled(!isEnabled)
    }
}

struct ForgotPasswordPageView<Content: View>: View {
    let image: Image = Image(CustomImages.ForgotPassword.defaultImage.fullPath)
    let text: Text
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: CustomSizes.ForgotPasswordPageView.verticalSpacing.size) {
            imageView
            textView
            contentView
        }
        .padding(.horizontal, CustomSizes.ForgotPasswordPageView.horizontalPadding.size)
    }

    private var imageView: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: CustomSizes.ForgotPasswordPageView.frameHeight.size)
    }

    private var textView: some View {
        text
            .body1Regular
            .multilineTextAlignment(.center)
    }

    private var contentView: some View {
        content
    }
}
