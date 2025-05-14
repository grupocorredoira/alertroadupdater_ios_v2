import Foundation

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var needsToPay = false
    @Published var isPurchasing = false

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
}
