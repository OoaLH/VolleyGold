//
//  GameScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import SpriteKit
import GameController

class GameScene: SKScene {
    var time: Int = Tuning.gameDuration {
        didSet {
            if time == 0 {
                removeAction(forKey: "timer")
                exitLevel()
            }
            timeLabel.text = "time: \(time)"
        }
    }
    
    var player1Skin: SkinType = {
        let skin = UserDefaults.standard.string(forKey: "Player 1") ?? "pig"
        return SkinType(rawValue: skin) ?? .pig
    }()
    
    var player2Skin: SkinType = {
        let skin = UserDefaults.standard.string(forKey: "Player 2") ?? "pig"
        return SkinType(rawValue: skin) ?? .pig
    }()
    
    var player1Name = "player1" {
        didSet {
            updateMoneyLabels()
        }
    }
    var player2Name = "player2" {
        didSet {
            updateMoneyLabels()
        }
    }
    
    override func sceneDidLoad() {
        configureViews()
        configurePhysics()
        configureControllers()
    }
    
    func configureViews() {
        initBackground()
        initPlayers()
        initGold()
        initBaskets()
        initGarbageBins()
        initLabels()
        initButtons()
        initTimer()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
    }
    
    func configureControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        connectControllers()
    }
    
    @objc func disconnectControllers() {
        isPaused = true
        addChild(dialog)
        dialog.position = CGPoint(x: 400, y: 196)
    }
    
    @objc func connectControllers() {
        for index in 0..<GCController.controllers().count {
            let controller = GCController.controllers()[index]
            controller.playerIndex = GCControllerPlayerIndex(rawValue: index) ?? .index1
            controller.extendedGamepad?.valueChangedHandler = controllerInputDetected
        }
    }
    
    func controllerInputDetected(gamePad: GCExtendedGamepad, element: GCControllerElement) {
        let player = gamePad.controller?.playerIndex == .index1 ? player1 : player2
        if element == gamePad.leftThumbstick {
            if gamePad.leftThumbstick.xAxis.value < 0 {
                player.direction = .left
            } else if gamePad.leftThumbstick.xAxis.value == 0 {
                player.direction = .none
            } else {
                player.direction = .right
            }
        } else if element == gamePad.buttonA {
            player.jump()
        } else if element == gamePad.dpad {
            if gamePad.dpad.left.isPressed {
                player.direction = .left
            } else if gamePad.dpad.right.isPressed {
                player.direction = .right
            } else {
                player.direction = .none
            }
        } else if element == gamePad.buttonHome && !isPaused {
            isPaused = true
            addChild(dialog)
            dialog.position = CGPoint(x: 400, y: 196)
        }
    }
    
    func initBackground() {
        let node = SKSpriteNode(imageNamed: "battle_background")
        // middle of the screen.
        node.position = CGPoint(x: 400, y: 196)
        // avoid white edges.
        node.size = CGSize(width: 800, height: 400)
        node.zPosition = UIConfig.backgroundZPosition
        addChild(node)
    }
    
    func initPlayers() {
        addPlayer(player: player1, at: UIConfig.player1Position)
        addPlayer(player: player2, at: UIConfig.player2Position)
    }
    
    func initGold() {
        addLargeGold(at: CGPoint(x: 400, y: 360))
    }
    
    func initBaskets() {
        let basket1 = Basket(player: player1)
        basket1.position = CGPoint(x: 30, y: 196)
        addChild(basket1)
        
        let basket2 = Basket(player: player2)
        basket2.position = CGPoint(x: 770, y: 196)
        addChild(basket2)
    }
    
    func initGarbageBins() {
        let garbageBin1 = GarbageBin()
        garbageBin1.position = CGPoint(x: 40, y: 30)
        addChild(garbageBin1)
        
        let garbageBin2 = GarbageBin()
        garbageBin2.position = CGPoint(x: 760, y: 30)
        addChild(garbageBin2)
    }
    
    func initLabels() {
        addChild(moneyLabel1)
        addChild(moneyLabel2)
        addChild(timeLabel)
    }
    
    func initButtons() {
        addChild(player1JumpButton)
        addChild(player2JumpButton)
        addChild(player1LeftButton)
        addChild(player2LeftButton)
        addChild(player1RightButton)
        addChild(player2RightButton)
        addChild(exitButton)
        addChild(closeButton)
    }
    
    func initTimer() {
        let second = SKAction.wait(forDuration: 1)
        let countDown = SKAction.run {
            self.time -= 1
        }
        let action = SKAction.sequence([second, countDown])
        run(SKAction.repeatForever(action), withKey: "timer")
    }
    
    func addPlayer(player: Player, at pos: CGPoint) {
        player.position = pos
        addChild(player)
    }
    
    func addLargeGold(at pos: CGPoint) {
        let gold = LargeGold()
        gold.physicsBody?.collisionBitMask = PhysicsCategory.all.rawValue
        gold.physicsBody?.restitution = 1
        gold.position = pos
        addChild(gold)
    }
    
    func updateMoneyLabels() {
        moneyLabel1.text = player1Name + ": $\(player1.money)"
        GameSession.shared.player1Money = player1.money
        moneyLabel2.text = player2Name + ": $\(player2.money)"
        GameSession.shared.player2Money = player2.money
    }
    
    func exitLevel() {
        GameSession.shared.nextLevel()
        if GameSession.shared.level > Tuning.totalNumberOfLevels {
            gameOver()
            return
        }
        let reveal = SKTransition.moveIn(with: .up, duration: 1)
        let newScene = ShopScene(size: size)
        newScene.scaleMode = .aspectFit
        view?.presentScene(newScene, transition: reveal)
    }
    
    func gameOver() {
        let reveal = SKTransition.moveIn(with: .down, duration: 1)
        let newScene = GameOverScene(score: score())
        newScene.scaleMode = .aspectFit
        view?.presentScene(newScene, transition: reveal)
    }
    
    func score() -> Int {
        return max(player1.money, player2.money)
    }
    
    // MARK: SpriteScene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == player1JumpButton {
                player1.jump()
            } else if touchedNode == player2JumpButton {
                player2.jump()
            } else if touchedNode == player1LeftButton {
                player1.direction = .left
            } else if touchedNode == player1RightButton {
                player1.direction = .right
            } else if touchedNode == player2LeftButton {
                player2.direction = .left
            } else if touchedNode == player2RightButton {
                player2.direction = .right
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == player1LeftButton || touchedNode == player1RightButton {
                player1.direction = .none
            } else if touchedNode == player2LeftButton || touchedNode == player2RightButton {
                player2.direction = .none
            } else if touchedNode == exitButton {
                removeAction(forKey: "timer")
                exitLevel()
            } else if touchedNode == closeButton && !isPaused {
                isPaused = true
                addChild(dialog)
                dialog.position = CGPoint(x: 400, y: 196)
            } else if touchedNode == dialog.okButton {
                GameCenterManager.shared.submitScore(score: score())
                exitToHome()
            } else if touchedNode == dialog.cancelButton {
                dialog.removeFromParent()
                isPaused = false
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch player1.direction {
        case .left:
            player1.goLeft()
        case .right:
            player1.goRight()
        default:
            break
        }
        
        switch player2.direction {
        case .left:
            player2.goLeft()
        case .right:
            player2.goRight()
        default:
            break
        }
    }
    
    lazy var player1: Player = {
        let node = Player(skinType: player1Skin)
        node.money = GameSession.shared.player1Money
        node.playerSpeed = Tuning.player1Speed
        node.playerJumpImpulse = Tuning.player1JumpImpulse
        node.basketSizeRate = Tuning.player1BasketSizeRate
        node.playerPrice = Tuning.player1GoldPrice
        return node
    }()
    
    lazy var player2: Player = {
        let node = Player(skinType: player2Skin)
        node.money = GameSession.shared.player2Money
        node.playerSpeed = Tuning.player2Speed
        node.playerJumpImpulse = Tuning.player2JumpImpulse
        node.basketSizeRate = Tuning.player2BasketSizeRate
        node.playerPrice = Tuning.player2GoldPrice
        return node
    }()
    
    // MARK: Button
    lazy var player1JumpButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "up_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 80, y: 160)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var player1LeftButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "left_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 80, y: 70)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var player1RightButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "right_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 170, y: 70)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var player2JumpButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "up_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 720, y: 160)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var player2LeftButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "left_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 630, y: 70)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var player2RightButton: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "right_button")
        node.alpha = 0.4
        node.position = CGPoint(x: 720, y: 70)
        node.zPosition = UIConfig.buttonZPosition
        return node
    }()
    
    lazy var exitButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "exit")
        let node = SKSpriteNode(texture: texture, color: .clear, size: CGSize(width: 40, height: 40))
        node.position = CGPoint(x: 680, y: 360)
        return node
    }()
    
    lazy var closeButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "close")
        let node = SKSpriteNode(texture: texture, color: .clear, size: CGSize(width: 20, height: 20))
        node.position = CGPoint(x: 15, y: 373)
        return node
    }()
    
    // MARK: label
    lazy var moneyLabel1: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = player1Name + ": $\(player1.money)"
        node.position = CGPoint(x: 30, y: 340)
        node.fontSize = 12
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
    
    lazy var moneyLabel2: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = player2Name + ": $\(player2.money)"
        node.position = CGPoint(x: 30, y: 320)
        node.fontSize = 12
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
    
    lazy var timeLabel: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = "time: \(time)"
        node.position = CGPoint(x: 720, y: 360)
        node.fontSize = 14
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
    
    lazy var dialog = Dialog()
}
