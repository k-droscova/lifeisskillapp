//
//  Buttons.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import Foundation
import SwiftUI

struct CameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: SFSSymbols.camera.rawValue)
        }
        .cameraButtonStyle()
    }
}

struct FlashButton: View {
    let action: () -> Void
    @Binding var flashOn: Bool
    
    var body: some View {
        Button(action: {
            action()
        }) {
            flashOn ?
            Image(CustomImages.flashOn.rawValue)
                .resizable()
                .frame(width: 16, height: 24)
            :
            Image(CustomImages.flashOff.rawValue)
                .resizable()
                .frame(width: 16, height: 24)
        }
        .cameraButtonStyle()
    }
}

struct HomeButton: View {
    let action: () -> Void
    let text: Text
    let color: Color
    
    var body: some View {
        Button(action: action) {
            text
        }
        .homeButtonStyle(color)
    }
}
