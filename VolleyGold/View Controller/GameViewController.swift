//
//  GameViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameSession.shared.newSession()
        
        let skView = SKView(frame: view.frame.inset(by: UIConfig.safeAreaInsets))
        skView.isMultipleTouchEnabled = true
        view = skView
        let scene = GameScene(size: UIConfig.defaultSize)
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
