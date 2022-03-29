//
//  Dialog.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

class Dialog: SKSpriteNode {
    var text: String
    
    init(text: String = "Are you sure to end the game? You will lose your progress.") {
        self.text = text
        
        let texture = SKTexture(imageNamed: "note")
        super.init(texture: texture, color: .clear, size: CGSize(width: 400, height: 380))
        
        zPosition = UIConfig.popupZPosition
        addChild(labelNode)
        addChild(okButton)
        addChild(cancelButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var labelNode: SKLabelNode = {
        let node = SKLabelNode()
        node.text = text
        node.fontName = "Chalkduster"
        node.fontSize = 20
        node.fontColor = .black
        node.preferredMaxLayoutWidth = 250
        node.position = CGPoint(x: -40, y: 50)
        node.numberOfLines = 0
        node.zPosition = zPosition + 1
        return node
    }()
    
    lazy var okButton: SKLabelNode = {
        let node = SKLabelNode()
        node.text = "OK"
        node.fontName = "Chalkduster"
        node.fontSize = 16
        node.fontColor = .red
        node.position = CGPoint(x: -30, y: -20)
        node.zPosition = zPosition + 1
        return node
    }()
    
    lazy var cancelButton: SKLabelNode = {
        let node = SKLabelNode()
        node.text = "cancel"
        node.fontName = "Chalkduster"
        node.fontSize = 16
        node.fontColor = .black
        node.position = CGPoint(x: 30, y: -20)
        node.zPosition = zPosition + 1
        return node
    }()
}
