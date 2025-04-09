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
                    // 🔐 Lógica para ya registrado (por ahora, vamos directo a welcome)
                    completion()
                } else {
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
                self?.isLoading = false
                switch result {
                case .success:
                    self?.authService.savePhoneToFirestore(phoneNumber: self?.phoneNumber ?? "")
                    onSuccess()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
