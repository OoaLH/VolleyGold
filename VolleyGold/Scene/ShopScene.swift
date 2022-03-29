//
//  ShopScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit
import GameplayKit

class ShopScene: SKScene {
    override func sceneDidLoad() {
        configureViews()
    }
    
    func configureViews() {
        initBackground()
        initGoods()
        initLabels()
        initButtons()
    }
    
    func initBackground() {
        let node = SKSpriteNode(imageNamed: "shop")
        node.position = CGPoint(x: 400, y: 196)
        node.size = CGSize(width: 800, height: 400)
        node.zPosition = UIConfig.backgroundZPosition
        addChild(node)
    }
    
    func initGoods() {
        let types = GoodsType.choose()
        var x = 100
        for good in types {
            let pos = CGPoint(x: x, y: 100)
            addGood(type: good, at: pos)
            x += 100
        }
    }
    
    func initLabels() {
        addChild(moneyLabel)
    }
    
    func initButtons() {
        addChild(nextLevelButton)
    }
    
    func addGood(type: GoodsType, at pos: CGPoint) {
        let good = Goods(type: type)
        good.anchorPoint = CGPoint(x: 0.5, y: 0)
        good.position = pos
        addChild(good)
        addPriceLabel(good: good)
    }
    
    func addPriceLabel(good: Goods) {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .center
        node.position = good.position - CGPoint(x: 0, y: 20)
        node.text = "$\(good.price)"
        node.fontColor = .systemGreen
        node.fontName = "Chalkduster"
        node.fontSize = 12
        addChild(node)
        good.priceLabel = node
    }
    
    func buy(good: Goods) {
        good.removeFromParent()
        good.priceLabel?.removeFromParent()
        GameSession.shared.player1Money -= good.price
        GameSession.shared.player2Money -= good.price
        moneyLabel.text = "money: \(GameSession.shared.player1Money + GameSession.shared.player2Money)"
        alertPopup(text: "-$\(good.price)")
        alertPopup(text: "-$\(good.price)")
        good.takeAffect()
    }
    
    func goToNextLevel() {
        let reveal = SKTransition.crossFade(withDuration: 1)
        let scene = GameScene(size: UIConfig.defaultSize)
        scene.size = size
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: reveal)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if let good = touchedNode as? Goods {
                if good.price <= GameSession.shared.player1Money && good.price <= GameSession.shared.player2Money {
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
    
    lazy var nextLevelButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "exit")
        node.size = CGSize(width: 40, height: 40)
        node.position = CGPoint(x: 680, y: 360)
        return node
    }()
    
    lazy var moneyLabel: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = "money: \(GameSession.shared.player1Money + GameSession.shared.player2Money)"
        node.position = CGPoint(x: 30, y: 360)
        node.fontSize = 14
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
}
