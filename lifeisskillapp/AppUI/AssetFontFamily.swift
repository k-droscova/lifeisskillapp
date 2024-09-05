//
//  AssetFontFamily.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import UIKit

struct AssetsFontFamily {
    struct Montserrat {
        static func black(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Black", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-ExtraBold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func hairline(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Hairline", size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
        }
        
        static func light(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        
        static func thin(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Thin", size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
        }
        
        static func ultraLight(size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-UltraLight", size: size) ?? UIFont.systemFont(ofSize: size, weight: .ultraLight)
        }
    }
    struct Roboto {
        static func black(size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        }
    }
}
