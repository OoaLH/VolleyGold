//
//  Basket.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class Basket: SKSpriteNode {
    var player: Player
    
    init(player: Player) {
        self.player = player
        
        let texture = SKTexture(imageNamed: "basket")
        let textSize = texture.size()
        let size = CGSize(width: textSize.width / player.basketSizeRate, height: textSize.height / player.basketSizeRate)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = UIConfig.buttonZPosition
        configurePhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePhysics() {
        if let texture = texture {
            physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: size)
        }
        physicsBody?.categoryBitMask = PhysicsCategory.basket.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.gold.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.none.rawValue
        physicsBody?.affectedByGravity = false
    }
}
