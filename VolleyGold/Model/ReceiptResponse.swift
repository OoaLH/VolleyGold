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
        // your non-consumable and non-renewing subscription receipts are in `in_app` array
        // your auto-renewable subscription receipts are in `latest_receipt_info` array
        guard let latestReceiptInfo = (data["in_app"] as? [[String: AnyObject]])?.first, let productId = latestReceiptInfo["product_id"] as? String else {
            return
        }
        self.productId = productId
        productType = ProductType(rawValue: productId)
    }
}

