//
//  OnlineShopScene.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit
import GameplayKit
import GameKit

class OnlineShopScene: ShopScene {
    var time: Int = 8 {
        didSet {
            if time == 0 {
                removeAction(forKey: "timer")
                goToNextLevel()
            }
            timeLabel.text = "time: \(time)"
        }
    }
    
    var match: GKMatch
    
    var role: UInt32
    
    var goods: [Goods?] = []
    
    var player1Name: String = "player1"
    var player2Name: String = "player2"
    
    var moneyReceived: Bool = false {
        didSet {
            checkIfCanStart()
        }
    }
    
    var goodsReceived: Bool = false {
        didSet {
            checkIfCanStart()
        }
    }
    
    var canStart: Bool = false {
        didSet {
            if canStart {
                start()
            }
        }
    }
    
    init(match: GKMatch, size: CGSize, role: UInt32) {
        self.match = match
        self.role = role
        
        super.init(size: size)
        if role == Role.player1 {
            player1Name = GKLocalPlayer.local.displayName
            player2Name = match.players.first?.displayName ?? "player2"
            sendMoneyData()
            moneyReceived = true
        } else {
            player1Name = match.players.first?.displayName ?? "player1"
            player2Name = GKLocalPlayer.local.displayName
        }
        match.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureViews() {
        initBackground()
        isUserInteractionEnabled = false
        if role == Role.player1 {
            initGoods()
        }
        initLabels()
    }
    
    override func initGoods() {
        let types = GoodsType.choose()
        var x = 100
        for good in types {
            let pos = CGPoint(x: x, y: 100)
            addGood(type: good, at: pos)
            x += 100
        }
        sendGoodsData(types: types)
    }
    
    override func addGood(type: GoodsType, at pos: CGPoint) {
        let good = Goods(type: type)
        good.anchorPoint = CGPoint(x: 0.5, y: 0)
        good.position = pos
        addChild(good)
        addPriceLabel(good: good)
        goods.append(good)
    }
    
    override func initLabels() {
        addChild(moneyLabel1)
        addChild(moneyLabel2)
        addChild(timeLabel)
        addChild(loadingLabel)
        checkTimeOut()
    }
    
    override func buy(good: Goods) {
        sendBuyData(good: good)
        let index = Int(good.position.x / 100) - 1
        goods[index] = nil
        good.removeFromParent()
        good.priceLabel?.removeFromParent()
        if (role == Role.player1) {
            GameSession.shared.player1Money -= good.price
            good.takeAffectToPlayer1()
        } else {
            GameSession.shared.player2Money -= good.price
            good.takeAffectToPlayer2()
        }
        updateMoneyLabels()
        alertPopup(text: "-$\(good.price)")
    }
    
    override func goToNextLevel() {
        let reveal = SKTransition.crossFade(withDuration: 1)
        let scene = OnlineGameScene(size: UIConfig.defaultSize)
        scene.match = match
        scene.size = size
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: reveal)
        
        GameCenterManager.shared.submitScore(score: role == Role.player1 ? GameSession.shared.player1Money : GameSession.shared.player2Money)
    }
    
    func updateMoneyLabels() {
        moneyLabel1.text = player1Name + ": $\(GameSession.shared.player1Money)"
        moneyLabel2.text = player2Name + ": $\(GameSession.shared.player2Money)"
    }
    
    func checkIfCanStart() {
        if goodsReceived && moneyReceived {
            canStart = true
        }
    }
    
    func sendMoneyData() {
        var message = Message(type: .money, x: Float(GameSession.shared.player1Money), y: Float(GameSession.shared.player2Money))
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendGoodsData(types: [GoodsType]) {
        var s = ""
        _ = types.map({ goods in
            s += String(goods.rawValue)
        })
        var message = Message(type: .goods, x: Float(s) ?? 1, y: 0)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendGoodsReply() {
        var message = Message(type: .goodsReply, x: 0, y: 0)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendBuyData(good: Goods) {
        var message = Message(type: .bought, x: Float(good.position.x/100), y: 0)
        let data = NSData(bytes: &message, length: MemoryLayout<Message>.stride)
        sendData(data: data)
    }
    
    func sendData(data: NSData) {
        do {
            try match.sendData(toAllPlayers: data as Data, with: .reliable)
        }
        catch {
            print("error")
        }
    }
    
    func checkTimeOut() {
        let wait = SKAction.wait(forDuration: Tuning.timeOutDuration)
        run(wait) { [unowned self] in
            if !canStart {
                match.disconnect()
                exitToHome(with: ConnectionError.timeout)
            }
        }
    }
    
    func initTimer() {
        let second = SKAction.wait(forDuration: 1)
        let countDown = SKAction.run {
            self.time -= 1
        }
        let action = SKAction.sequence([second, countDown])
        run(SKAction.repeatForever(action), withKey: "timer")
    }
    
    func start() {
        loadingLabel.removeFromParent()
        initTimer()
        isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if let good = touchedNode as? Goods {
                let money = role == Role.player1 ? GameSession.shared.player1Money : GameSession.shared.player2Money
                if good.price <= money {
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
    
    // MARK: label
    lazy var moneyLabel1: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = player1Name + ": $\(GameSession.shared.player1Money)"
        node.position = CGPoint(x: 30, y: 340)
        node.fontSize = 12
        node.fontName = "Chalkduster"
        node.fontColor = .brown
        return node
    }()
    
    lazy var moneyLabel2: SKLabelNode = {
        let node = SKLabelNode()
        node.horizontalAlignmentMode = .left
        node.text = player2Name + ": $\(GameSession.shared.player2Money)"
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

extension OnlineShopScene: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let pointer = UnsafeMutablePointer<Message>.allocate(capacity: MemoryLayout<Message>.stride)
        let nsData = NSData(data: data)
        nsData.getBytes(pointer, length: MemoryLayout<Message>.stride)
        let message = pointer.move()
        switch message.type {
        case .bought:
            receiveBought(x: Int(message.x))
        case .goods:
            receiveGoods(types: String(Int(message.x)))
        case .goodsReply:
            receiveGoodsReply()
        case .money:
            receiveMoneyData(money1: Int(message.x), money2: Int(message.y))
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        if state == .disconnected {
            exitToHome(with: ConnectionError.teammateDisconnected)
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        exitToHome(with: error as? ConnectionError)
    }
    
    func receiveBought(x: Int) {
        if let good = goods[x - 1] {
            good.removeFromParent()
            good.priceLabel?.removeFromParent()
            if (role == Role.player2) {
                GameSession.shared.player1Money -= good.price
                good.takeAffectToPlayer1()
            } else {
                GameSession.shared.player2Money -= good.price
                good.takeAffectToPlayer2()
            }
            alertPopup(text: "-$\(good.price)")
            goods[x - 1] = nil
        }
    }
    
    func receiveGoods(types: String) {
        var x = 100
        for char in types {
            let pos = CGPoint(x: x, y: 100)
            let type = GoodsType(rawValue: char.wholeNumberValue ?? 1) ?? .drink
            addGood(type: type, at: pos)
            x += 100
        }
        sendGoodsReply()
        goodsReceived = true
    }
    
    func receiveGoodsReply() {
        goodsReceived = true
    }
    
    func receiveMoneyData(money1: Int, money2: Int) {
        GameSession.shared.player1Money = money1
        GameSession.shared.player2Money = money2
        
        updateMoneyLabels()
        moneyReceived = true
    }
}
