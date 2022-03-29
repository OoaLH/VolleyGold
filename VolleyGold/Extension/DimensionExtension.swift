//
//  DimensionExtension.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

protocol Dimension {
    var height: CGFloat { get }
    var width: CGFloat { get }
    var realHeight: CGFloat { get }
    var realWidth: CGFloat { get }
}

extension CGFloat: Dimension {
    var height: CGFloat {
        return self * UIConfig.realHeight / UIConfig.defaultHeight
    }
    
    var width: CGFloat {
        return self * UIConfig.realWidth / UIConfig.defaultWidth
    }
    
    var realHeight: CGFloat {
        return self * UIConfig.defaultHeight / UIConfig.realHeight
    }
    
    var realWidth: CGFloat {
        return self * UIConfig.defaultWidth / UIConfig.realWidth
    }
}

extension Float: Dimension {
    var height: CGFloat {
        return CGFloat(self) * UIConfig.realHeight / UIConfig.defaultHeight
    }
    
    var width: CGFloat {
        return CGFloat(self) * UIConfig.realWidth / UIConfig.defaultWidth
    }
    
    var realHeight: CGFloat {
        return CGFloat(self) * UIConfig.defaultHeight / UIConfig.realHeight
    }
    
    var realWidth: CGFloat {
        return CGFloat(self) * UIConfig.defaultWidth / UIConfig.realWidth
    }
}

extension Double: Dimension {
    var height: CGFloat {
        return CGFloat(self) * UIConfig.realHeight / UIConfig.defaultHeight
    }
    
    var width: CGFloat {
        return CGFloat(self) * UIConfig.realWidth / UIConfig.defaultWidth
    }
    
    var realHeight: CGFloat {
        return CGFloat(self) * UIConfig.defaultHeight / UIConfig.realHeight
    }
    
    var realWidth: CGFloat {
        return CGFloat(self) * UIConfig.defaultWidth / UIConfig.realWidth
    }
}

extension Int: Dimension {
    var height: CGFloat {
        return CGFloat(self) * UIConfig.realHeight / UIConfig.defaultHeight
    }
    
    var width: CGFloat {
        return CGFloat(self) * UIConfig.realWidth / UIConfig.defaultWidth
    }
    
    var realHeight: CGFloat {
        return CGFloat(self) * UIConfig.defaultHeight / UIConfig.realHeight
    }
    
    var realWidth: CGFloat {
        return CGFloat(self) * UIConfig.defaultWidth / UIConfig.realWidth
    }
}
