//
//  InviteFriendQRView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import SwiftUI

struct InviteFriendView: View {
    let qrImage: UIImage
    
    var body: some View {
        OnboardingPageView(
            image:  Image(uiImage: qrImage)
                .interpolation(.none),
            text: Text("invite.instructions")
        )
    }
}
