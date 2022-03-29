//
//  UIConfig.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

struct UIConfig {
    static let player1Position: CGPoint = CGPoint(x: 300, y: 100)
    static let player2Position: CGPoint = CGPoint(x: 500, y: 100)
    
    static let defaultWidth: CGFloat = 800
    static let defaultHeight: CGFloat = 393
    static let defaultSize: CGSize = CGSize(width: defaultWidth, height: defaultHeight)
    
    static let backgroundZPosition: CGFloat = -1
    static let defaultZPosition: CGFloat = 0
    static let buttonZPosition: CGFloat = 1
    static let popupZPosition: CGFloat = 2
    
    static var safeAreaInsets: UIEdgeInsets = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }()

    static var realHeight: CGFloat = {
        return UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
    }()

    static var realWidth: CGFloat = {
        return UIScreen.main.bounds.width - safeAreaInsets.left - safeAreaInsets.right
    }()
}
