import Foundation
import FirebaseAuth
import FirebaseFirestore
/*
class UsersHandler: ObservableObject {
    static let shared = UsersHandler()
    private let db = Firestore.firestore()
    private let usersCollection = "users" // Reemplaza con FIREBASE_USERS_COLLECTION_NAME

    /// Agrega un usuario a Firestore si no existe
    func addUser(uid: String, user: User, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection(usersCollection).document(uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error al verificar usuario: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let document = document, document.exists {
                print("Usuario ya existe en Firestore")
                completion(true)
            } else {
                let userData: [String: Any] = [
                    "fullPhoneNumber": user.fullPhoneNumber,
                    "creationDate": Timestamp(date: user.creationDate), // 🔹 Convertir Date a Timestamp
                    "expirationDate": Timestamp(date: user.expirationDate), // 🔹 Convertir Date a Timestamp
                    "trialPeriodDays": user.trialPeriodDays,
                    "purchaseDate": user.purchaseDate != nil ? Timestamp(date: user.purchaseDate!) : NSNull(),
                    "purchaseToken": user.purchaseToken,
                    "forcePurchase": user.forcePurchase
                ]

                userRef.setData(userData) { error in
                    if let error = error {
                        print("Error al guardar usuario: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Usuario \(uid) creado en Firestore.")
                        completion(true)
                    }
                }
            }
        }
    }

    /// Obtiene un usuario desde Firestore usando su número de teléfono
    func getUser(phoneNumber: String, completion: @escaping (User?) -> Void) {
        db.collection(usersCollection)
            .whereField("fullPhoneNumber", isEqualTo: phoneNumber)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener usuario: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("Usuario no encontrado")
                    completion(nil)
                    return
                }

                let data = document.data()
                let user = User(
                    fullPhoneNumber: data["fullPhoneNumber"] as? String ?? "",
                    creationDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
                    expirationDate: (data["expirationDate"] as? Timestamp)?.dateValue() ?? Date(),
                    trialPeriodDays: data["trialPeriodDays"] as? Int ?? 0,
                    purchaseDate: (data["purchaseDate"] as? Timestamp)?.dateValue(),
                    purchaseToken: data["purchaseToken"] as? String ?? "",
                    forcePurchase: data["forcePurchase"] as? Bool ?? false
                )
                completion(user)
            }
    }

    /// Verifica si un usuario necesita comprar
    func checkUserNeedsToPurchase(user: User) -> Bool {
        if user.forcePurchase {
            print("Compra forzada para usuario \(user.fullPhoneNumber)")
            return true
        } else {
            return user.purchaseToken.isEmpty
        }
    }

    /// Verifica si el usuario está autenticado en Firebase
    func isUserAuthenticated(phoneNumber: String) -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        return currentUser.phoneNumber == phoneNumber
    }

    /// Cierra sesión en Firebase
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Usuario desconectado.")
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
*/
