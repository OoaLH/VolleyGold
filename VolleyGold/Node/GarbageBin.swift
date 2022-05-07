//
//  GarbageBin.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class GarbageBin: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "garbage")
        let textSize = texture.size()
        let size = CGSize(width: textSize.width / 2, height: textSize.height / 2)
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
