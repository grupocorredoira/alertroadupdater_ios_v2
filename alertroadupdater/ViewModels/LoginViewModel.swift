import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    @Published var isCodeSent: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService = LoginService()
    
    func checkIfPhoneExists(fullPhoneNumber: String, completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        
        authService.checkPhoneInFirestore(phoneNumber: fullPhoneNumber) { [weak self] exists in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if exists {
                    // 🔐 El usuario ya existe, continuamos
                    completion()
                } else {
                    // ✅ No existe → enviar código de verificación
                    self.sendVerificationCode(to: fullPhoneNumber)
                }
            }
        }
    }
    
    func sendVerificationCode(to phoneNumber: String) {
        isLoading = true
        authService.sendVerificationCode(to: phoneNumber) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isCodeSent = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func verifyCode(onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil

        authService.verifyCode(code: verificationCode) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success:
                    guard let uid = Auth.auth().currentUser?.uid,
                          let phone = Auth.auth().currentUser?.phoneNumber else {
                        self.errorMessage = "Error: no se encontró UID o número"
                        return
                    }

                    self.authService.checkPhoneInFirestore(phoneNumber: phone) { exists in
                        if exists {
                            print("✅ Usuario ya existe en Firestore")
                            onSuccess()
                        } else {
                            self.authService.createUser(uid: uid, phoneNumber: phone) { error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self.errorMessage = "Error al crear usuario: \(error.localizedDescription)"
                                    } else {
                                        print("✅ Usuario creado correctamente")
                                        onSuccess()
                                    }
                                }
                            }
                        }
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }


    private func checkOrCreateUser(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let phone = Auth.auth().currentUser?.phoneNumber else {
            self.errorMessage = "Error al obtener información del usuario."
            return
        }

        authService.checkPhoneInFirestore(phoneNumber: phone) { [weak self] exists in
            guard let self = self else { return }

            if exists {
                completion()
            } else {
                let newUser = User(
                    fullPhoneNumber: phone,
                    creationDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    trialPeriodDays: 7,
                    purchaseDate: nil,
                    purchaseToken: "",
                    forcePurchase: false
                )

                self.authService.createUser(uid: uid, phoneNumber: phone) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = "Error al crear usuario: \(error.localizedDescription)"
                        } else {
                            completion()
                        }
                    }
                }
            }
        }
    }

}
