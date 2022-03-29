//
//  SkinType.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum SkinType: String, CaseIterable {
    case pig = "pig"
    case cat = "cat"
    case lion = "lion"
    case crocodile = "crocodile"
    case penguin = "penguin"
    case shiba = "shiba"
    
    static var purchasable: [SkinType] {
        return [cat, lion, crocodile, penguin, shiba]
    }
    
    var product: SkinProduct {
        return SkinProduct(name: self.rawValue)
    }
    
    var index: Int {
        return SkinType.allCases.firstIndex(of: self) ?? 0
    }
    
    var battle: String {
        return self.rawValue + "_battle"
    }
}
