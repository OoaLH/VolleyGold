//
//  PurchaseManager.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import StoreKit

protocol PurchaseManagerDelegate: AnyObject {
    func purchaseManager(didFinishProductRequestWith products: [SKProduct]?, isSuccess: Bool)
    func purchaseManager(didFailWithError error: Error?)
    func purchaseManager(didUpdatePurchaseStatusOf productType: ProductType?)
    func purchaseManagerRestoreFinished()
}

extension PurchaseManagerDelegate {
    func purchaseManager(didFinishProductRequestWith products: [SKProduct]?, isSuccess: Bool) {}
    func purchaseManager(didFailWithError error: Error?) {}
    func purchaseManager(didUpdatePurchaseStatusOf productType: ProductType?) {}
    func purchaseManagerRestoreFinished() {}
}

class PurchaseManager: NSObject {
    public static let shared = PurchaseManager()
    
    public var purchasedProduct: ProductType? {
        didSet {
            delegate?.purchaseManager(didUpdatePurchaseStatusOf: purchasedProduct)
        }
    }
    
    weak var delegate: PurchaseManagerDelegate?
    
    private let productIdentifiers: Set<String> = Set(ProductType.all.map({$0.rawValue}))
    private var productsRequest: SKProductsRequest?
    private var products: [SKProduct]?
    
    public func requestProducts() {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func buyProduct() {
        guard canMakePayments() else {
            delegate?.purchaseManager(didFailWithError: PurchaseError.cannotMakePayments)
            return
        }
        guard let product = products?.first else {
            delegate?.purchaseManager(didFailWithError: PurchaseError.noProductsAvailable)
            return
        }
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func checkPurchaseStatus(_ completionHandler: @escaping (ProductType?) -> Void) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptUrl, options: .alwaysMapped).base64EncodedString() else {
            print("receipt missing, refresh receipt")
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
            return
        }
        sendReceiptToAppStore(receipt: receipt, completionHandler)
    }
    
    private func sendReceiptToAppStore(receipt: String, _ completionHandler: @escaping (ProductType?) -> Void, debug: Bool = false) {
        var url: URL
        if debug {
            url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        } else {
            url = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        }
        var request = URLRequest(url: url)
        let requestData: [String: Any] = ["receipt-data": receipt,
                                          "password": "6ef1b54c35bf4d1a94c0a5d1082b9657",
                                          "exclude-old-transactions": false]
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            if let error = error {
                print(error)
                completionHandler(nil)
                return
            }
            DispatchQueue.main.async { [unowned self] in
                if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if jsonData["status"] as? Int == 21007 {
                        sendReceiptToAppStore(receipt: receipt, completionHandler, debug: true)
                    } else {
                        let subscriptionResponse = ReceiptResponse(data: jsonData)
                        completionHandler(subscriptionResponse.productType)
                    }
                } else {
                    print("data invalid")
                    completionHandler(nil)
                }
            }
        }.resume()
    }
    
    public func updatePurchaseStatus() {
        checkPurchaseStatus() { [weak self] productType in
            self?.purchasedProduct = productType
        }
    }
}

extension PurchaseManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        self.products = products
        delegate?.purchaseManager(didFinishProductRequestWith: products, isSuccess: true)
        productsRequest = nil
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKReceiptRefreshRequest {
            purchasedProduct = nil
            print("No receipt.")
            return
        }
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        delegate?.purchaseManager(didFinishProductRequestWith: nil, isSuccess: false)
        productsRequest = nil
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            print("Get refreshed receipt.")
            updatePurchaseStatus()
        }
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else { return }
            
            switch (transaction.transactionState) {
            case .purchased:
                purchased(transaction: transaction, productType: productType)
            case .failed:
                failed(transaction: transaction)
            case .restored:
                restored(transaction: transaction, productType: productType)
            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.purchaseManager(didFailWithError: error)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.purchaseManagerRestoreFinished()
    }
    
    private func purchased(transaction: SKPaymentTransaction, productType: ProductType) {
        print("purchase...")
        
        completeSubscribe(transaction: transaction, productType: productType)
    }
    
    private func restored(transaction: SKPaymentTransaction, productType: ProductType) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        completeSubscribe(transaction: transaction, productType: productType)
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?, transactionError.code != SKError.paymentCancelled.rawValue {
            delegate?.purchaseManager(didFailWithError: transactionError)
        } else {
            delegate?.purchaseManager(didFailWithError: PurchaseError.noProductPurchased)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func completeSubscribe(transaction: SKPaymentTransaction, productType: ProductType) {
        purchasedProduct = productType
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
