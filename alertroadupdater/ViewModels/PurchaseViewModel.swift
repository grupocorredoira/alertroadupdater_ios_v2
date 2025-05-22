import Foundation
import SwiftUI

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var needsToPay = false
    @Published var isPurchasing = false

    var purchaseButtonColor: Color {
        isPurchasing ? Color.gray.opacity(0.4) : Color.blue
    }

    // ✅ Cargar producto y verificar estado de pago desde Firestore
    func start() async {
        await PurchaseService.shared.start()
        self.needsToPay = PurchaseService.shared.needsToPay
    }

    // ✅ Ejecutar la compra con StoreKit y actualizar estado local
    func makePurchase() async {
        self.isPurchasing = true
        await PurchaseService.shared.makePurchase()
        self.needsToPay = PurchaseService.shared.needsToPay
        self.isPurchasing = false
    }

    func refreshPaymentStatus() async {
        await PurchaseService.shared.checkHaveToPay()
    }
}
