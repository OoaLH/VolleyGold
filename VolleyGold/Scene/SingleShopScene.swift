//
//  SingleShopScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-29.
//

import SpriteKit
import GameplayKit
import GameKit

class SingleShopScene: ShopScene {
    override func initLabels() {
        addChild(moneyLabel1)
        addChild(moneyLabel2)
    }
    
    override func buy(good: Goods) {
        good.removeFromParent()
        good.priceLabel?.removeFromParent()
        GameSession.shared.player1Money -= good.price
        alertPopup(text: "-$\(good.price)")
        good.takeAffectToPlayer1()
        moneyLabel1.text = "Me: $\(GameSession.shared.player1Money)"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if let good = touchedNode as? Goods {
                if good.price <= GameSession.shared.player1Money {
                    buy(good: good)
                } else {
                    alertPopup(text: "not enough money")
                }
            }
            else if touchedNode == nextLevelButton {
                goToNextLevel()
            }
        }
    }
    
    override func goToNextLevel() {
        let reveal = SKTransition.crossFade(withDuration: 1)
        let scene = SingleGameScene(size: UIConfig.defaultSize)
        scene.size = size
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: reveal)
    }
    
    lazy var moneyLabel1: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = "Me: $\(GameSession.shared.player1Money)"
        node.position = CGPoint(x: 30, y: 340)
        node.fontSize = 12
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
    
    lazy var moneyLabel2: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = "Computer: $\(GameSession.shared.player2Money)"
        node.position = CGPoint(x: 30, y: 320)
        node.fontSize = 12
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
}
