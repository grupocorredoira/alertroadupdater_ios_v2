import Foundation
import StoreKit

class BillingHandler: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = BillingHandler()
    private var product: SKProduct?
    private let productID = "acceso_ilimitado" // Reemplaza con tu SKU real

    var purchaseCompletion: ((Bool) -> Void)?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProduct()
    }

    private func fetchProduct() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }

    func purchaseProduct(completion: @escaping (Bool) -> Void) {
        guard let product = product else {
            completion(false)
            return
        }

        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            self.purchaseCompletion = completion
        } else {
            completion(false)
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.purchaseCompletion = completion
    }

    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let fetchedProduct = response.products.first {
            self.product = fetchedProduct
        }
    }

    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseCompletion?(true)
            case .failed, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseCompletion?(false)
            default:
                break
            }
        }
    }
}
