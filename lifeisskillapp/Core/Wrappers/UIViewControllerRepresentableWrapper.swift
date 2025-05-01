//
//  UIViewControllerRepresentableWrapper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import SwiftUI
import UIKit

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    let content: UIViewController
    
    init(_ content: UIViewController) {
        self.content = content
    }
        
    func makeUIViewController(context: Context) -> UIViewController {
        let size = content.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        content.preferredContentSize = size
        return content
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
