import FirebaseAuth
import FirebaseFirestore

class LoginService {
    private let db = Firestore.firestore()
    private let usersCollection = "users"

    func checkPhoneInFirestore(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        db.collection(usersCollection)
            .whereField("phoneNumber", isEqualTo: phoneNumber)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents, !docs.isEmpty {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }

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
                userInfo: [NSLocalizedDescriptionKey: "No se encontró el ID de verificación en UserDefaults."]
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

    func savePhoneToFirestore(phoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(usersCollection).document(uid).setData([
            "phoneNumber": phoneNumber
        ])
    }
}
