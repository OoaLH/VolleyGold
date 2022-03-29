//
//  GameOverScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-28.
//

import SpriteKit
import GameplayKit
import GameKit

class GameOverScene: SKScene {
    let score: Int
    
    init(score: Int) {
        self.score = score
        super.init(size: UIConfig.defaultSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        backgroundColor = .white
        addChild(gameOverLabel)
        addChild(scoreLabel)
        addChild(returnButton)
        
        if GKLocalPlayer.local.isAuthenticated {
            GameCenterManager.shared.submitScore(score: score)
            alertPopup(text: "score submitted", at: CGPoint(x: 400, y: 100))
        }
        else {
            alertPopup(text: "login to game center to submit your score", at: CGPoint(x: 400, y: 100))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == returnButton {
                exitToHome()
            }
        }
    }
    
    lazy var gameOverLabel: SKLabelNode = {
        let node = SKLabelNode()
        node.text = "Game Over"
        node.fontName = "Chalkduster"
        node.fontSize = 40
        node.fontColor = .red
        node.position = CGPoint(x: 400, y: 250)
        return node
    }()
    
    lazy var scoreLabel: SKLabelNode = {
        let node = SKLabelNode()
        node.text = "score: \(score)"
        node.fontName = "Chalkduster"
        node.fontSize = 40
        node.fontColor = .red
        node.position = CGPoint(x: 400, y: 200)
        return node
    }()
    
    lazy var returnButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "exit")
        let node = SKSpriteNode(texture: texture, color: .clear, size: CGSize(width: 40, height: 40))
        node.position = CGPoint(x: 680, y: 360)
        return node
    }()
}

