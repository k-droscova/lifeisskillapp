//
//  Theme.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation
import UIKit

struct Theme<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol ThemeCompatible {
    associatedtype CompatibleType
    static var theme: Theme<CompatibleType>.Type { get set }
    var theme: Theme<CompatibleType> { get set }
}

extension ThemeCompatible {
    static var theme: Theme<Self>.Type {
        get { Theme<Self>.self }
        set { }
    }
    
    var theme: Theme<Self> {
        get { Theme(self) }
        set { }
    }
}

extension UIColor: ThemeCompatible {}

extension Theme where Base: UIColor {
    static var lisPink: UIColor { UIColor(hex: 0xEB008B) }
    static var lisGreen: UIColor { UIColor(hex: 0x0DB04B) }
    static var lisBlue: UIColor { UIColor(hex: 0x3C9BD5) }
    static var lisGrayTextFieldTitle: UIColor { UIColor(hex: 0x939598) }
    static var scanWrongRed: UIColor { UIColor(hex: 0xD50000) }

    static var pointSport: UIColor { UIColor(hex: 0xEB008B) }
    static var pointCulture: UIColor { UIColor(hex: 0x3C9BD5) }
    static var pointEnvironment: UIColor { UIColor(hex: 0x0DB04B) }
}
