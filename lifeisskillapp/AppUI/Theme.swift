//
//  Theme.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import UIKit
import ACKategories


extension Theme where Base: UIColor { // all app colors should be available in UIColor.theme namespace
    static var lisPink: UIColor { return UIColor(hex: 0xEB008B) }
    static var lisGreen: UIColor { return UIColor(hex: 0x0DB04B) }
    static var lisBlue: UIColor { return UIColor(hex: 0x3C9BD5) }
    /// 0x939598
    static var lisGrayTextFieldTitle: UIColor { return UIColor(hex: 0x939598) }
    static var scanWrongRed: UIColor { return UIColor(hex: 0xD50000) }

    static var pointSport: UIColor { return UIColor(hex: 0xEB008B) }
    static var pointCulture: UIColor { return UIColor(hex: 0x3C9BD5) }
    static var pointEnvironment: UIColor { return UIColor(hex: 0x0DB04B) }
}
