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

        authService.checkPhoneInFirebase(fullPhoneNumber: fullPhoneNumber) { [weak self] exists in
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
                    self?.errorMessage = self?.mapFirebaseError(error)
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

                    self.authService.checkPhoneInFirebase(fullPhoneNumber: phone) { exists in
                        if exists {
                            print("✅ Usuario ya existe en Firestore")
                            PreferencesManager.shared.savePhoneNumberWithPrefix(phone)
                            onSuccess()
                        } else {
                            self.authService.createUser(uid: uid, phoneNumber: phone) { error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self.errorMessage = "Error al crear usuario: \(error.localizedDescription)"
                                    } else {
                                        print("✅ Usuario creado correctamente")
                                        PreferencesManager.shared.savePhoneNumberWithPrefix(phone)
                                        onSuccess()
                                    }
                                }
                            }
                        }
                    }

                case .failure(let error):
                    self.errorMessage = self.mapFirebaseError(error)
                }
            }
        }
    }

    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        case AuthErrorCode.networkError.rawValue:
            return "Error de red, comprueba tu conexión"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Has hecho demasiados intentos, inténtalo de nuevo en 24 horas"
        case AuthErrorCode.invalidVerificationCode.rawValue:
            return "El código introducido no es válido. Revisa el SMS e inténtalo otra vez."
        case AuthErrorCode.invalidPhoneNumber.rawValue:
            return "El número de teléfono no es válido. Revisa el formato."
        default:
            return nsError.localizedDescription
        }
    }
}
