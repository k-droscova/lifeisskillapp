//
//  View.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 31.07.2024.
//

import Foundation
import SwiftUI

extension View {
    func hosting() -> UIHostingController<some View> {
        UIHostingController(rootView: self)
    }
}
