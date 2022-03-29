//
//  LargeGold.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class LargeGold: SKSpriteNode {
    init() {
        let goldTexture = SKTexture(imageNamed: "large_gold")
        let textSize = goldTexture.size()
        let size = CGSize(width: textSize.width / 3, height: textSize.height / 3)
        super.init(texture: goldTexture, color: .clear, size: size)
        configurePhysiscs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configurePhysiscs() {
        if let texture = texture {
            physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: size)
        }
        physicsBody?.categoryBitMask = PhysicsCategory.mineral.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.basket.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.none.rawValue
    }
}
