//
//  BitMaskExtension.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

extension UInt32 {
    var isGold: Bool {
        return self == 0b1
    }
    
    var isBasket: Bool {
        return self == 0b10
    }
    
    var isPlayer: Bool {
        return self == 0b101
    }
    
    var isGround: Bool {
        return self == 0b1001
    }
}
