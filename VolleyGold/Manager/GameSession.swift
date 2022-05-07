//
//  GameSession.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum GameMode: Int {
    case basket = 0
    case volley
}

class GameSession {
    static let shared = GameSession()
    
    private init() {}
    
    var mode: GameMode = .basket
    
    var level: Int = 1
    
    var player1Money: Int = 0
    var player2Money: Int = 0
    
    var otherSkin: SkinType?
    
    func newSession(mode: GameMode = .basket) {
        self.mode = .basket
        player1Money = 0
        player2Money = 0
        otherSkin = nil
        level = 1
    }
    
    func nextLevel() {
        level += 1
        Tuning.recoverTuning()
        mode = GameMode(rawValue: (level - 1) % 2) ?? .basket
    }
}
