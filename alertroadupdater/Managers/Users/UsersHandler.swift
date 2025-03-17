import Foundation
import FirebaseAuth
import FirebaseFirestore

class UsersHandler {
    static let shared = UsersHandler()
    private let db = Firestore.firestore()
    private let usersCollection = "users" // Reemplaza con FIREBASE_USERS_COLLECTION_NAME

    func addUser(uid: String, user: User, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection(usersCollection).document(uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("Usuario ya existe en Firestore")
                completion(true)
            } else {
                do {
                    try userRef.setData(from: user)
                    print("Usuario \(uid) creado en Firestore.")
                    completion(true)
                } catch {
                    print("Error al guardar usuario: \(error)")
                    completion(false)
                }
            }
        }
    }

    func getUser(phoneNumber: String, completion: @escaping (User?) -> Void) {
        db.collection(usersCollection)
            .whereField("fullPhoneNumber", isEqualTo: phoneNumber)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener usuario: \(error)")
                    completion(nil)
                } else if let document = snapshot?.documents.first {
                    let user = try? document.data(as: User.self)
                    completion(user)
                } else {
                    print("Usuario no encontrado")
                    completion(nil)
                }
            }
    }

    func checkUserNeedsToPurchase(user: User) -> Bool {
        if user.forcePurchase {
            print("Compra forzada para usuario \(user.fullPhoneNumber)")
            return true
        } else {
            return user.purchaseToken.isEmpty
        }
    }

    func isUserAuthenticated(phoneNumber: String) -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        return currentUser.phoneNumber == phoneNumber
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Usuario desconectado.")
        } catch {
            print("Error al cerrar sesión: \(error)")
        }
    }
}
