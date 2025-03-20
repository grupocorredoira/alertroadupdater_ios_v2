import Foundation
import FirebaseAuth
import Combine
/*
class LoginViewModel: ObservableObject {
    private let usersHandler: UsersHandler
    private let prefs: PreferencesManager
    private var cancellables = Set<AnyCancellable>()

    @Published var isPhoneValid = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var verificationID: String?
    @Published var isAuthenticated = false

    private let auth = Auth.auth()

    init(usersHandler: UsersHandler, prefs: PreferencesManager) {
        self.usersHandler = usersHandler
        self.prefs = prefs
        self.isAuthenticated = prefs.getIsAuthenticated()
    }

    /// Valida el número de teléfono según el prefijo del país.
    func validatePhoneNumber(prefix: String, phone: String) {
        switch prefix {
        case "+351", "+33":
            isPhoneValid = phone.count == 9
        case "+34":
            isPhoneValid = phone.count == 9 && (phone.hasPrefix("6") || phone.hasPrefix("7"))
        default:
            isPhoneValid = phone.count >= 7
        }
    }

    /// Envía un código de verificación por SMS al número de teléfono dado.
    func sendVerificationCode(phoneNumber: String) {
        isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let verificationID = verificationID {
                    self.verificationID = verificationID
                    self.prefs.saveTokenLogin(verificationID)  // Solo guarda si no es `nil`
                }
            }
        }
    }

    /// Verifica el código ingresado por el usuario y autentica en Firebase.
    func verifyCode(code: String) {
        guard let verificationID = verificationID else {
            errorMessage = "No hay un código de verificación disponible."
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)

        auth.signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isAuthenticated = true
                    self.prefs.saveIsAuthenticated(true)
                }
            }
        }
    }

    /// Cierra la sesión del usuario actual.
    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.prefs.saveIsAuthenticated(false)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error cerrando sesión: \(error.localizedDescription)"
            }
        }
    }
}
*/
