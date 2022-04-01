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
        gold?.position = CGPoint(x: 400, y: 360)
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
}
