//
//  GameScene+SKPhysicsContactDelegate.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import SpriteKit
import GameplayKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask.isGold && secondBody.categoryBitMask.isBasket {
            if let gold = firstBody.node as? LargeGold, let basket = secondBody.node as? Basket {
                basketCaughtGold(basket: basket, gold: gold)
            } else if let gold = firstBody.node as? LargeGold, let garbageBin = secondBody.node as? GarbageBin {
                garbageBinCaughtGold(garbageBin: garbageBin, gold: gold)
            }
        }
    }
    
    func basketCaughtGold(basket: Basket, gold: LargeGold) {
        basket.player.gainMoney()
        updateMoneyLabels()
        alertPopup(text: "+$\(basket.player.playerPrice)", at: basket.player.position - CGPoint(x: 40, y: 40))
        gold.removeFromParent()
        
        initGold()
    }
    
    func garbageBinCaughtGold(garbageBin: GarbageBin, gold: LargeGold) {
        gold.removeFromParent()
        
        initGold()
    }
}

