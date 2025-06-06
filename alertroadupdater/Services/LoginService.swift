import FirebaseAuth
import FirebaseFirestore

class LoginService {
    private let db = Firestore.firestore()
    private let usersCollection = "users"

    /// Verifica si un número ya existe en Firestore
    func checkPhoneInFirebase(fullPhoneNumber: String, completion: @escaping (Bool) -> Void) {
        db.collection(usersCollection)
            .whereField("fullPhoneNumber", isEqualTo: fullPhoneNumber)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents, !docs.isEmpty {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }

    /// Envía código de verificación vía Firebase Auth
    func sendVerificationCode(to phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(.failure(error))
            } else if let verificationID = verificationID {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(.success(()))
            } else {
                let unknownError = NSError(
                    domain: "FirebaseAuth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el ID de verificación."]
                )
                completion(.failure(unknownError))
            }
        }
    }

    func verifyCode(code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            let error = NSError(
                domain: "FirebaseAuth",
                code: -2,
                //No se encontró el ID de verificación en UserDefaults, es decir, se envió solicitud a firebase, pero no
                //se recibió correctamente el verification id, puede que por internet, puede que por número incorrecto
                userInfo: [NSLocalizedDescriptionKey: "Error en el código de verificación, por favor, cierra la aplicación e inténtalo más tarde"]
            )
            completion(.failure(error))
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func createUser(uid: String, phoneNumber: String, completion: @escaping (Error?) -> Void) {
        let now = Date()
        let expiration = Calendar.current.date(byAdding: .day, value: 365, to: now)!

        let data: [String: Any] = [
            "fullPhoneNumber": phoneNumber,
            "creationDate": now,
            "expirationDate": expiration,
            "trialPeriodDays": 365,
            "purchaseDate": NSNull(),
            "purchaseToken": "",
            "forcePurchase": false
        ]

        db.collection("users").document(uid).setData(data) { error in
            if let error = error {
                print("❌ Error al crear usuario: \(error.localizedDescription)")
                completion(error)
            } else {
                print("✅ Usuario nuevo creado en Firestore con purchaseDate null")
                completion(nil)
            }
        }
    }

}
