//
//  Tuning.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

struct Tuning {
    static let gameDuration: Int = 30
    static let timeOutDuration: TimeInterval = 30
    
    static let frameRate: TimeInterval = 60
    static let frame: TimeInterval = 1 / frameRate
    
    static let totalNumberOfLevels: Int = 5
    
    static let defaultGoldPrice: Int = 250
    static let highGoldPrice: Int = 300
    static var player1GoldPrice = defaultGoldPrice
    static var player2GoldPrice = defaultGoldPrice
    
    static let defaultPlayerSpeed: Int = 3
    static let highPlayerSpeed: Int = 5
    static var player1Speed = defaultPlayerSpeed
    static var player2Speed = defaultPlayerSpeed
    
    static let defaultPlayerJumpImpulse: Int = 60
    static let highPlayerJumpImpulse: Int = 100
    static var player1JumpImpulse = defaultPlayerJumpImpulse
    static var player2JumpImpulse = defaultPlayerJumpImpulse
    
    static let defaultBasketSizeRate: CGFloat = 2
    static let largeBasketSizeRate: CGFloat = 1
    static var player1BasketSizeRate = defaultBasketSizeRate
    static var player2BasketSizeRate = defaultBasketSizeRate
    
    static func recoverTuning() {
        player1GoldPrice = defaultGoldPrice
        player2GoldPrice = defaultGoldPrice
        player1Speed = defaultPlayerSpeed
        player2Speed = defaultPlayerSpeed
        player1JumpImpulse = defaultPlayerJumpImpulse
        player2JumpImpulse = defaultPlayerJumpImpulse
        player1BasketSizeRate = defaultBasketSizeRate
        player2BasketSizeRate = defaultBasketSizeRate
    }
    
    static func increaseSpeed() {
        player1Speed = highPlayerSpeed
        player2Speed = highPlayerSpeed
        player1JumpImpulse = highPlayerJumpImpulse
        player2JumpImpulse = highPlayerJumpImpulse
    }
    
    static func increaseSpeedForPlayer1() {
        player1Speed = highPlayerSpeed
        player1JumpImpulse = highPlayerJumpImpulse
    }
    
    static func increaseSpeedForPlayer2() {
        player2Speed = highPlayerSpeed
        player2JumpImpulse = highPlayerJumpImpulse
    }
    
    static func increasePrice() {
        player1GoldPrice = highGoldPrice
        player2GoldPrice = highGoldPrice
    }
    
    static func increasePriceForPlayer1() {
        player1GoldPrice = highGoldPrice
    }
    
    static func increasePriceForPlayer2() {
        player2GoldPrice = highGoldPrice
    }
    
    static func increaseBasketSize() {
        player1BasketSizeRate = largeBasketSizeRate
        player2BasketSizeRate = largeBasketSizeRate
    }
    
    static func increaseBasketSizeForPlayer1() {
        player1BasketSizeRate = largeBasketSizeRate
    }
    
    static func increaseBasketSizeForPlayer2() {
        player2BasketSizeRate = largeBasketSizeRate
    }
}
