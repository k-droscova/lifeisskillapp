//
//  Image.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import SwiftUI
import UIKit

extension Image {
    func toUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self.resizable())
        let view = controller.view
        
        let targetSize = view?.intrinsicContentSize ?? CGSize(width: 100, height: 100)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
}
