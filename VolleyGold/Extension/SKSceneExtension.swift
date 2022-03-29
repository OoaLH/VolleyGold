//
//  SKSceneExtension.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit

extension SKScene {
    func alertPopup(text: String, at pos: CGPoint = CGPoint(x: UIConfig.defaultWidth / 2, y: UIConfig.defaultHeight / 2)) {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .center
        node.text = text
        node.position = pos
        node.fontName = "Chalkduster"
        node.fontSize = 20
        node.fontColor = .red
        addChild(node)
        let action = SKAction.moveBy(x: 0, y: 50, duration: 1)
        let fadeAction = SKAction.fadeOut(withDuration: 1)
        node.run(SKAction.sequence([action, fadeAction])) {
            node.removeFromParent()
        }
    }
    
    func exitToHome(with error: ConnectionError?) {
        DispatchQueue.main.async {
            if let vc = self.view?.window?.rootViewController as? HomeViewController {
                vc.dismissWithError(error: error)
            }
        }
    }
    
    func exitToHome() {
        DispatchQueue.main.async {
            self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
