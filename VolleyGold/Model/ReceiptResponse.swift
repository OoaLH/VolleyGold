//
//  ReceiptResponse.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-27.
//

import Foundation

struct ReceiptResponse {
    var productId: String?
    var productType: ProductType?
    
    init(data: [String: Any]) {
        guard let latestReceiptInfo = (data["latest_receipt_info"] as? [[String: AnyObject]])?.first, let productId = latestReceiptInfo["product_id"] as? String else {
            return
        }
        self.productId = productId
        productType = ProductType(rawValue: productId)
    }
}

