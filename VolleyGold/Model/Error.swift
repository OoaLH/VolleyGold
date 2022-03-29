//
//  Error.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import Foundation

enum ConnectionError: Error {
    case timeout
    case teammateDisconnected
    case teammateNotFound
    case selfExited
    
    var localizedDescription: String {
        switch self {
        case .timeout:
            return NSLocalizedString("Connection timeout.", comment: "ConnectionError")
        case .teammateDisconnected:
            return NSLocalizedString("Your teammate is disconnected.", comment: "ConnectionError")
        case .teammateNotFound:
            return NSLocalizedString("Your teammate is not found.", comment: "ConnectionError")
        case .selfExited:
            return NSLocalizedString("You have exited the game.", comment: "ConnectionError")
        }
    }
}

enum PurchaseError: LocalizedError {
    case noProductPurchased
    case noProductsAvailable
    case cannotMakePayments
    
    var errorDescription: String {
        switch self {
        case .noProductPurchased:
            return "No subscription purchased"
        case .noProductsAvailable:
            return "No products available"
        case .cannotMakePayments:
            return "Can't make payments"
        }
    }
}
