//
//  LocalGameScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-29.
//

import SpriteKit
import GameplayKit
import GameKit

class SingleGameScene: GameScene {
    var gold: LargeGold?
    
    override func initButtons() {
        player1LeftButton.position = CGPoint(x: 80, y: 70)
        player1RightButton.position = CGPoint(x: 170, y: 70)
        player1JumpButton.position = CGPoint(x: 720, y: 160)
        addChild(player1LeftButton)
        addChild(player1RightButton)
        addChild(player1JumpButton)
        addChild(closeButton)
    }
    
    override func initGold() {
        gold = LargeGold()
        gold?.physicsBody?.collisionBitMask = PhysicsCategory.all.rawValue
        gold?.physicsBody?.restitution = 1
        let left = Bool.random()
        if left {
            gold?.position = CGPoint(x: 200, y: 360)
        } else {
            gold?.position = CGPoint(x: 600, y: 360)
        }
        addChild(gold!)
    }
    
    override func score() -> Int {
        return player1.money
    }
    
    override func controllerInputDetected(gamePad: GCExtendedGamepad, element: GCControllerElement) {
        if element == gamePad.leftThumbstick {
            if gamePad.leftThumbstick.xAxis.value < 0 {
                player1.direction = .left
            } else if gamePad.leftThumbstick.xAxis.value == 0 {
                player1.direction = .none
            } else {
                player1.direction = .right
            }
        } else if element == gamePad.buttonA {
            player1.jump()
        } else if element == gamePad.dpad {
            if gamePad.dpad.left.isPressed {
                player1.direction = .left
            } else if gamePad.dpad.right.isPressed {
                player1.direction = .right
            } else {
                player1.direction = .none
            }
        } else if element == gamePad.buttonHome {
            isPaused = true
            addChild(dialog)
            dialog.position = CGPoint(x: 400, y: 196)
        }
    }
    
    override func exitLevel() {
        GameSession.shared.nextLevel()
        if GameSession.shared.level > Tuning.totalNumberOfLevels {
            gameOver()
            return
        }
        let reveal = SKTransition.moveIn(with: .up, duration: 1)
        let newScene = SingleShopScene(size: size)
        newScene.scaleMode = .aspectFit
        view?.presentScene(newScene, transition: reveal)
    }
    
    override func update(_ currentTime: TimeInterval) {
        configurePlayer2Move()
        super.update(currentTime)
    }
    
    func configurePlayer2Move() {
        switch GameSession.shared.mode {
        case .volley:
            configurePlayer2VolleyMove()
        case .basket:
            configurePlayer2BasketMove()
        }
    }
    
    func configurePlayer2BasketMove() {
        guard let gold = gold else { return }
        if player2.position.x > gold.position.x + 50 {
            player2.direction = .left
        } else if player2.position.x > gold.position.x {
            player2.direction = .left
            if player2.position.y >= gold.position.y {
                player2.jump()
            }
        } else if player2.position.x > gold.position.x - 50 {
            if player2.direction == .right {
                player2.jump()
            }
        } else {
            player2.direction = .right
        }
        if (player2.position - player1.position).length <= 50 {
            player2.jump()
        }
    }
    
    func configurePlayer2VolleyMove() {
        guard let gold = gold else { return }
        
        // jumping
        if let y = player2.physicsBody?.velocity.dy, abs(y) > 0.1 {
            if player2.position.x > gold.position.x {
                player2.direction = .left
            } else {
                player2.direction = .right
            }
            return
        }
        
        guard let dy = gold.physicsBody?.velocity.dy else { return }
        
        // gold flying left
        if gold.position.x >= 400 && gold.physicsBody?.velocity.dx ?? 0 < 0 {
            if player2.position.y > gold.position.y - abs(dy * 0.3) && player2.position.x < gold.position.x + 150 && player2.position.x > gold.position.x - 150 {
                player2.jump()
            } else if player2.position.x > gold.position.x {
                player2.direction = .left
            } else {
                player2.direction = .right
            }
            return
        }
        
        // gold at opponent or at ground
        if gold.position.x < 400 || gold.position.y < 80 {
            if player2.position.x < 630 {
                player2.direction = .right
            } else if player2.position.x > 650 {
                player2.direction = .left
            }
            return
        }
        
        if player2.position.y < gold.position.y - abs(dy * 0.3) && dy < 0 {
            // gold falling
            let x = predictGoldPosition() + 30
            if player2.position.x < x {
                player2.direction = .right
            } else {
                player2.direction = .left
            }
        } else if dy > 0 {
            // gold uproaring
            if player2.position.x > gold.position.x + 150 {
                player2.direction = .left
            } else {
                player2.direction = .right
            }
        } else if player2.position.y > gold.position.y - abs(dy * 0.3) {
            // gold near enough
            if player2.position.x > 750 || (player2.position.x < gold.position.x + 80 && player2.position.x > gold.position.x - 80) {
                player2.jump()
            } else if player2.position.x > gold.position.x + 150 {
                player2.direction = .left
            } else {
                player2.direction = .right
            }
        }
    }
    
    func predictGoldPosition() -> CGFloat {
        let ratio = 150.0
        let dy = ((gold?.position.y ?? 0) - 130) / ratio
        let vy = abs(gold?.physicsBody?.velocity.dy ?? 0) / ratio
        let g = abs(physicsWorld.gravity.dy)
        let t = (sqrt((vy * vy) + 2 * dy * g) - vy) / g
        let vx = gold?.physicsBody?.velocity.dx ?? 0
        var x = gold?.position.x ?? 0
        var d = abs(vx * t)
        var left = vx < 0
        while d > 0 {
            if left {
                let tempD = x - 400
                if d >= tempD {
                    x = 400
                    d -= tempD
                    left = false
                } else {
                    x -= d
                    d = 0
                }
            } else {
                let tempD = 800 - x
                if d >= tempD {
                    x = 800
                    d -= tempD
                    left = true
                } else {
                    x += d
                    d = 0
                }
            }
        }
        return x
    }
}
