//
//  OnlineGameScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit
import GameplayKit
import GameKit

class OnlineGameScene: GameScene {
    var match: GKMatch? {
        didSet {
            guard let match = match else {
                return
            }
            teamMate = match.players.first
            match.delegate = self
        }
    }
    
    var role: UInt32 = Role.player1 {
        didSet {
            initPlayerSkins()
            initButtons()
        }
    }
    
    var teamMate: GKPlayer? {
        didSet {
            guard let teamMate = teamMate else {
                match?.disconnect()
                exitToHome(with: ConnectionError.teammateNotFound)
                return
            }
            let name = GKLocalPlayer.local.displayName
            if teamMate.displayName < name {
                role = Role.player2
                player1Name = teamMate.displayName
                player2Name = name
            }
            else {
                role = Role.player1
                player1Name = name
                player2Name = teamMate.displayName
            }
        }
    }
    
    var skinReceived: Bool = false {
        didSet {
            if skinReceived {
                start()
            }
        }
    }
    
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    
    var gold: LargeGold?
    var player: Player!
    var otherPlayer: Player!
    
    var playerPositionMessage: Message?
    var goldPositionMessage: Message?
    
    let skin: SkinType = {
        let skin = UserDefaults.standard.string(forKey: "Online") ?? "pig"
        return SkinType(rawValue: skin) ?? .pig
    }()
    
    override func configureViews() {
        initBackground()
        isUserInteractionEnabled = false
        initPlayers()
        initLabels()
        initBaskets()
        initGarbageBins()
    }
    
    override func initLabels() {
        super.initLabels()
        
        addChild(loadingLabel)
        
        dialog.isHidden = true
        dialog.position = CGPoint(x: 400, y: 196)
        addChild(dialog)
        
        checkTimeOut()
    }
    
    override func initButtons() {
        leftButton = role == Role.player1 ? player1LeftButton : player2LeftButton
        rightButton = role == Role.player1 ? player1RightButton : player2RightButton
        jumpButton = role == Role.player1 ? player1JumpButton : player2JumpButton
        leftButton.position = CGPoint(x: 80, y: 70)
        rightButton.position = CGPoint(x: 170, y: 70)
        jumpButton.position = CGPoint(x: 720, y: 160)
        addChild(leftButton)
        addChild(rightButton)
        addChild(jumpButton)
        addChild(closeButton)
    }
    
    override func initGold() {
        gold = LargeGold()
        gold?.physicsBody?.collisionBitMask = PhysicsCategory.all.rawValue
        gold?.physicsBody?.restitution = 1
        gold?.position = CGPoint(x: 400, y: 360)
        addChild(gold!)
    }
    
    override func exitLevel() {
        GameSession.shared.nextLevel()
        if GameSession.shared.level > Tuning.totalNumberOfLevels {
            gameOver()
            return
        }
        
        guard let match = match else {
            return
        }
        
        let reveal = SKTransition.moveIn(with: .up, duration: 1)
        let newScene = OnlineShopScene(match: match, size: size, role: role)
        newScene.scaleMode = .aspectFit
        view?.presentScene(newScene, transition: reveal)
    }
    
    override func gameOver() {
        match?.disconnect()
        
        super.gameOver()
    }
    
    override func score() -> Int {
        return player.money
    }
    
    func initPlayerSkins() {
        player = role == Role.player1 ? player1 : player2
        otherPlayer = role == Role.player1 ? player2 : player1
        setSelfSkin()
        if let otherSkin = GameSession.shared.otherSkin {
            otherPlayer.setSkin(skinType: otherSkin)
            skinReceived = true
        } else {
            sendSkinData()
        }
    }
    
    func setSelfSkin() {
        player.setSkin(skinType: skin)
    }
    
    func setOtherSkin(skinIndex: Int) {
        let skin = SkinType.allCases[skinIndex]
        GameSession.shared.otherSkin = skin
        
        otherPlayer.setSkin(skinType: skin)
        
        sendSkinReply()
    }
    
    func checkTimeOut() {
        let wait = SKAction.wait(forDuration: Tuning.timeOutDuration)
        let exit = SKAction.run { [unowned self] in
            exitToHome(with: ConnectionError.timeout)
        }
        run(SKAction.sequence([wait, exit]), withKey: "timeout")
    }
    
    func sendSkinData() {
        var message = Message(type: .skin, x: Float(skin.index), y: 0)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendSkinReply() {
        var message = Message(type: .skinReply, x: 0, y: 0)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendPlayerPositionData(direction: PlayerDirection, x: Float, y: Float, dy: Float) {
        var message = Message(type: .playerPosition, x: Float(direction.rawValue), y: x, z: y, w:dy)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendGoldData(x: Float, y: Float, dx: Float, dy: Float) {
        var message = Message(type: .goldPosition, x: Float(gold?.position.x ?? 0), y: Float(gold?.position.y ?? 0), z: Float(gold?.physicsBody?.velocity.dx ?? 0), w: Float(gold?.physicsBody?.velocity.dy ?? 0))
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendData(data: NSData) {
        do {
            try match?.sendData(toAllPlayers: data as Data, with: .reliable)
        }
        catch {
            print("error")
        }
    }
    
    func start() {
        removeAction(forKey: "timeout")
        loadingLabel.removeFromParent()
        isUserInteractionEnabled = true
        initTimer()
        initGold()
    }
    
    func readPlayerPositionData() {
        guard let message = playerPositionMessage else { return }
        receivePlayerPosition(direction: Int(message.x), x: message.y, y: message.z, dy: message.w)
        playerPositionMessage = nil
    }
    
    func readGoldPositionData() {
        guard let message = goldPositionMessage else { return }
        receiveGoldPosition(x: message.x, y: message.y, dx: message.z, dy: message.w)
        goldPositionMessage = nil
    }
    
    func receivePlayerPosition(direction: Int, x: Float, y: Float, dy: Float) {
        otherPlayer.removeAllActions()
        otherPlayer.position = CGPoint(x: Double(x), y: Double(y))
        otherPlayer.direction = PlayerDirection(rawValue: direction) ?? .none
        otherPlayer.run(.move(by: CGVector(dx: 0, dy: CGFloat(dy)), duration: Tuning.frameRate))
    }
    
    func receiveGoldPosition(x: Float, y: Float, dx: Float, dy: Float) {
        gold?.removeAllActions()
        gold?.position = CGPoint(x: Double(x), y: Double(y))
        gold?.run(.move(by: CGVector(dx: CGFloat(dx), dy: CGFloat(dy)), duration: Tuning.frameRate))
    }
    
    override func update(_ currentTime: TimeInterval) {
        readPlayerPositionData()
        sendPlayerPositionData(direction: player.direction, x: Float(player.position.x), y: Float(player.position.y), dy: Float(player.physicsBody?.velocity.dy ?? 0))
        if player == player1 {
            sendGoldData(x: Float(gold?.position.x ?? 0), y: Float(gold?.position.y ?? 0), dx: Float(gold?.physicsBody?.velocity.dx ?? 0), dy: Float(gold?.physicsBody?.velocity.dy ?? 0))
            
        } else {
            readGoldPositionData()
        }
        
        super.update(currentTime)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == leftButton || touchedNode == rightButton {
                player.direction = .none
            } else if touchedNode == closeButton {
                dialog.isHidden = false
            } else if touchedNode == dialog.okButton {
                GameCenterManager.shared.submitScore(score: player.money)
                match?.disconnect()
                exitToHome(with: ConnectionError.selfExited)
            } else if touchedNode == dialog.cancelButton {
                dialog.isHidden = true
            }
        }
    }
    
    lazy var loadingLabel: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .center
        node.text = "Loading..."
        node.fontSize = 20
        node.fontName = "Chalkduster"
        node.fontColor = .red
        node.position = CGPoint(x: 400, y: 186)
        return node
    }()
}

extension OnlineGameScene: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let pointer = UnsafeMutablePointer<Message>.allocate(capacity: MemoryLayout<Message>.stride)
        let nsData = NSData(data: data)
        nsData.getBytes(pointer, length: MemoryLayout<Message>.stride)
        let message = pointer.move()
        switch message.type {
        case .skin:
            setOtherSkin(skinIndex: Int(message.x))
        case .skinReply:
            skinReceived = true
        case .playerPosition:
            playerPositionMessage = message
        case .goldPosition:
            goldPositionMessage = message
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        if state == .disconnected {
            match.disconnect()
            exitToHome(with: ConnectionError.teammateDisconnected)
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        match.disconnect()
        exitToHome(with: error as? ConnectionError)
    }
}
