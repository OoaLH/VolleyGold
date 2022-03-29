//
//  GoodsType.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

enum GoodsType: Int, CaseIterable {
    case drink = 1
    case basket
    case price
    
    static func choose() -> [GoodsType] {
        return GoodsType.allCases.shuffled()
    }
    
    var texture: SKTexture {
        switch self {
        case .drink:
            return SKTexture(imageNamed: "drink")
        case .basket:
            return SKTexture(imageNamed: "basket")
        case .price:
            return SKTexture(imageNamed: "price")
        }
    }
}
