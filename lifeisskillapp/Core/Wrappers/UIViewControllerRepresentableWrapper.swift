//
//  UIViewControllerRepresentableWrapper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import SwiftUI
import UIKit

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
        if let parentView = uiViewController.view.superview {
            uiViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                uiViewController.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                uiViewController.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                uiViewController.view.topAnchor.constraint(equalTo: parentView.topAnchor),
                uiViewController.view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
        }
    }
}
