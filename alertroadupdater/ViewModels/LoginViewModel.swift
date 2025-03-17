import Foundation
import FirebaseAuth
import Combine

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

    func sendVerificationCode(phoneNumber: String) {
        isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else {
                    self.verificationID = verificationID
                    self.prefs.saveTokenLogin(verificationID ?? "")
                    self.isLoading = false
                }
            }
        }
    }

    func verifyCode(code: String) {
        guard let verificationID = verificationID else {
            errorMessage = "No verification ID available."
            return
        }
        let
