import Foundation
import StoreKit
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PurchaseService: ObservableObject {
    
    static let shared = PurchaseService()
    
    private init() {}
    
    private let productID = AppConstants.productID
    private let firestore = Firestore.firestore()
    
    @Published var product: Product?
    @Published var needsToPay: Bool = false
    @Published var isPurchasing: Bool = false
    
    // ✅ Cargar el producto de StoreKit
    func loadProduct() async {
        do {
            let storeProducts = try await Product.products(for: [productID])
            self.product = storeProducts.first
        } catch {
            print("Error al cargar productos: \(error.localizedDescription)")
        }
    }
    
    // ✅ Verificar si debe pagar, consultando Firestore
    func checkHaveToPay() async {
        guard let user = Auth.auth().currentUser else {
            print("Usuario no autenticado.")
            self.needsToPay = false
            return
        }
        
        do {
            let doc = try await firestore.collection(AppConstants.firebaseUsersCollectionName).document(user.uid).getDocument()
            if let data = doc.data(),
               let expirationTimestamp = data["expirationDate"] as? Timestamp {
                let expirationDate = expirationTimestamp.dateValue()
                let now = Date()
                self.needsToPay = now >= expirationDate
                print("*** Expira el \(expirationDate). Hoy es \(now). ¿Debe pagar? \(self.needsToPay)")
            } else {
                print("No se encontró expirationDate en Firestore.")
                self.needsToPay = false
            }
        } catch {
            print("Error consultando Firestore: \(error.localizedDescription)")
        }
    }
    
    // ✅ Secuencia inicial al abrir la app
    func start() async {
        await loadProduct()
        await checkHaveToPay()
    }
    
    // ✅ Realizar compra y actualizar Firestore con fecha de expiración
    func makePurchase() async {
        guard let product = self.product else {
            print("Producto no cargado.")
            return
        }
        
        isPurchasing = true
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updateFirestore(transactionID: transaction.id)
                    self.needsToPay = false
                } else {
                    print("Transacción no verificada")
                    self.needsToPay = true
                }
            case .userCancelled:
                print("Usuario canceló la compra.")
            default:
                print("Resultado de compra inesperado: \(result)")
            }
        } catch {
            print("Error al hacer la compra: \(error.localizedDescription)")
        }
        
        isPurchasing = false
    }
    
    // ✅ Actualizar Firestore con fecha y token tras una compra exitosa
    private func updateFirestore(transactionID: UInt64) async {
        guard let user = Auth.auth().currentUser else {
            print("No hay usuario autenticado.")
            return
        }
        
        let purchaseDate = Date()
        let expirationDate = Calendar.current.date(byAdding: .year, value: 3, to: purchaseDate)!
        
        let updates: [String: Any] = [
            "purchaseDate": purchaseDate,
            "expirationDate": expirationDate,
            "purchaseToken": String(transactionID)
        ]
        
        do {
            try await firestore.collection(AppConstants.firebaseUsersCollectionName)
                .document(user.uid)
                .updateData(updates)
            print("*** Firestore actualizado correctamente.")
        } catch {
            print("Error al actualizar Firestore: \(error.localizedDescription)")
        }
    }
    
    // ✅ Añadir función de escucha para transacciones pendientes
    func listenForPendingTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            print("💳 Transacción pendiente verificada: \(transaction.id)")
            await handleTransactionFromUpdate(transaction)
        }
    }
    
    // ✅ Manejar transacción fuera del flujo normal de compra
    func handleTransactionFromUpdate(_ transaction: StoreKit.Transaction) async {
        await transaction.finish()
        await updateFirestore(transactionID: transaction.id)
        self.needsToPay = false
    }
    
}
