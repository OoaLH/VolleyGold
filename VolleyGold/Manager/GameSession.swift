//
//  GameSession.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum GameMode {
    case local
    case online
}

class GameSession {
    static let shared = GameSession()
    
    private init() {}
    
    var mode: GameMode = .local
    
    var level: Int = 1
    
    var player1Money: Int = 0
    var player2Money: Int = 0
    
    var otherSkin: SkinType?
    
    func newSession(mode: GameMode = .local) {
        self.mode = mode
        player1Money = 0
        player2Money = 0
        otherSkin = nil
    }
    
    func nextLevel() {
        level += 1
        Tuning.recoverTuning()
    }
}
