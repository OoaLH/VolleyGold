//
//  Player.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class Player: SKSpriteNode {
    var direction: PlayerDirection = .none
    
    var money: Int = 0
    
    var skinType: SkinType
    
    var basket: Basket?
    var basketSizeRate: CGFloat = Tuning.defaultBasketSizeRate
    var playerSpeed = Tuning.defaultPlayerSpeed
    var playerJumpImpulse = Tuning.defaultPlayerJumpImpulse
    var playerPrice = Tuning.defaultGoldPrice
    
    init(skinType: SkinType) {
        self.skinType = skinType
        let texture = SKTexture(imageNamed: skinType.battle)
        var size = texture.size()
        size = CGSize(width: size.width * 1.5, height: size.height * 1.5)
        super.init(texture: texture, color: .clear, size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.4)
        configurePhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePhysics() {
        if let texture = texture {
            physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.1, size: size)
        }
        physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.none.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.gold.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
    }
    
    func setSkin(skinType: SkinType) {
        self.skinType = skinType
        
        let texture = SKTexture(imageNamed: skinType.battle)
        
        self.texture = texture
        size = texture.size()
        size = CGSize(width: size.width * 1.5, height: size.height * 1.5)
    }
    
    func gainMoney() {
        money += playerPrice
    }
    
    func jump() {
        if let y = physicsBody?.velocity.dy, abs(y) > 0.1 {
            return
        }
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: playerJumpImpulse))
    }
    
    func goLeft() {
        run(.move(by: CGVector(dx: -playerSpeed, dy: 0), duration: Tuning.frame))
    }
    
    func goRight() {
        run(.move(by: CGVector(dx: playerSpeed, dy: 0), duration: Tuning.frame))
    }
}
