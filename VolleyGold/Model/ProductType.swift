//
//  ProductType.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-27.
//

import Foundation

enum ProductType: String {
    case skins = "zhangyifan.VolleyGold.skins"
    
    static var all: [ProductType] {
        return [skins]
    }
}
