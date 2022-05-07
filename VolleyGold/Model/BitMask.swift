//
//  BitMask.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum PhysicsCategory: UInt32 {
    case none = 0
    case gold = 0b1
    case basket = 0b10
    case player = 0b101
    case ground = 0b1001
    case all = 0xffffffff
}
