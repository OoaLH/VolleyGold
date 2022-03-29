//
//  SkinProduct.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

struct SkinProduct {
    var image: UIImage
    var name: String
    
    init(name: String) {
        self.name = name
        self.image = UIImage(named: name + "_battle")!
    }
}
