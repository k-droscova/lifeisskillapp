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
            Image(systemName: SFSSymbols.camera.rawValue)
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
            Image(CustomImages.flashOn.rawValue)
                .resizable()
                .frame(width: 16, height: 24)
            :
            Image(CustomImages.flashOff.rawValue)
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

struct LoginButton: View {
    let action: () -> Void
    let text: Text
    let enabledColor: Color
    let disabledColor: Color
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            text
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal, 20)
                .background(isEnabled ? enabledColor : disabledColor)
                .cornerRadius(20)
        }
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .disabled(!isEnabled)
    }
}
