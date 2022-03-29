//
//  Goods.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class Goods: SKSpriteNode {
    var type: GoodsType
    
    var price: Int
    
    var priceLabel: SKLabelNode?
    
    init(type: GoodsType) {
        self.price = Int.random(in: 10...500)
        self.type = type
        let texture = type.texture
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takeAffect() {
        switch type {
        case .drink:
            Tuning.increaseSpeed()
        case .basket:
            Tuning.increaseBasketSize()
        case .price:
            Tuning.increasePrice()
        }
    }
    
    func takeAffectToPlayer1() {
        switch type {
        case .drink:
            Tuning.increaseSpeedForPlayer1()
        case .basket:
            Tuning.increaseBasketSizeForPlayer1()
        case .price:
            Tuning.increasePriceForPlayer1()
        }
    }
    
    func takeAffectToPlayer2() {
        switch type {
        case .drink:
            Tuning.increaseSpeedForPlayer2()
        case .basket:
            Tuning.increaseBasketSizeForPlayer2()
        case .price:
            Tuning.increasePriceForPlayer2()
        }
    }
}
