//
//  OnlineGameViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class OnlineGameViewController: UIViewController {
    var match: GKMatch
    
    init(match: GKMatch) {
        self.match = match
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameSession.shared.newSession()
        
        let skView = SKView(frame: view.frame.inset(by: UIConfig.safeAreaInsets))
        skView.isMultipleTouchEnabled = true
        view = skView
        let scene = OnlineGameScene(size: UIConfig.defaultSize)
        scene.match = match
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

