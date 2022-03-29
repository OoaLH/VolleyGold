//
//  GameMessage.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum MessageType: Int {
    case bought = 0
    
    case goods
    case goodsReply
    
    case money
    
    case skin
    case skinReply
    
    case playerPosition
    case goldPosition
}

struct Message {
    var type: MessageType
    var x: Float = 0
    var y: Float = 0
    var z: Float = 0
    var w: Float = 0
}
