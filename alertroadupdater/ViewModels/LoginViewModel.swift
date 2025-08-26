import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    // TODO - BORRAR, hay que dejar isCodeSent a false, lo pongo en true para pruebas
    @Published var isCodeSent: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var errorMessage: String?
    
    /// -------------------------------------------------------------------------- Verificación del teléfono móvil
    ///
    @Published var isPhoneValid: Bool = false
    @Published var phoneErrorMessage: String? = nil
    @Published var phoneBorderColor: UIColor = UIColor.gray
    var canAccess: Bool {
        isPhoneValid && !isLoading
    }
    // Color dinámico para el botón
    var accessButtonColor: Color {
        canAccess ? Color.green : Color.gray.opacity(0.4)
    }
    
    /// -------------------------------------------------------------------------- Verificación del código SMS
    ///
    @Published var isCodeValid: Bool = false
    @Published var codeBorderColor: UIColor = UIColor.gray
    @Published var codeErrorMessage: String? = nil
    var canVerify: Bool {
        isCodeValid && !isLoading
    }
    var verifyButtonColor: Color {
        canVerify ? Color.green : Color.gray.opacity(0.4)
    }
    
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
                        self.errorMessage = "user_data_missing".localized
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
                                        self.errorMessage = String(format: "user_creation_error".localized, error.localizedDescription)
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
    
    // Dentro de mapFirebaseError(_:)
    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.networkError.rawValue:
            return "network_error".localized // 🔁 Localizado
        case AuthErrorCode.tooManyRequests.rawValue:
            return "too_many_requests".localized // 🔁 Localizado
        case AuthErrorCode.invalidVerificationCode.rawValue:
            return "invalid_verification_code".localized // 🔁 Localizado
        case AuthErrorCode.invalidPhoneNumber.rawValue:
            return "invalid_phone_number".localized // 🔁 Localizado
        default:
            return nsError.localizedDescription
        }
    }
    
    func validatePhoneNumber(prefix: String) {
        let sanitized = phoneNumber.filter { $0.isNumber }
        
        let (isValid, errorMessage): (Bool, String?) = {
            switch prefix {
            case "+351", "+33":
                let valid = sanitized.count == 9
                return (valid, valid ? nil : "number_must_have_9_digits".localized)
                
            case "+34":
                let valid = sanitized.count == 9 && (sanitized.hasPrefix("6") || sanitized.hasPrefix("7"))
                if !valid {
                    if sanitized.count != 9 {
                        return (false, "es_mobile_must_have_9_digits".localized)
                    } else {
                        return (false, "es_mobile_must_start_with_6_or_7".localized)
                    }
                }
                return (true, nil)
                
            default:
                let valid = sanitized.count >= 7
                return (valid, valid ? nil : "number_must_have_at_least_9_digits".localized)
            }
        }()
        
        self.phoneNumber = sanitized
        self.isPhoneValid = isValid
        self.phoneErrorMessage = errorMessage
        
        // 👉 Color del borde según validación
        self.phoneBorderColor = {
            if sanitized.isEmpty {
                return UIColor.gray
            } else if isValid {
                return UIColor.systemGreen
            } else {
                return UIColor.systemRed
            }
        }()
    }
    
    func validateVerificationCode() {
        let sanitized = verificationCode.filter { $0.isNumber }
        
        let isValid = sanitized.count == 6
        self.verificationCode = sanitized
        self.isCodeValid = isValid
        self.codeErrorMessage = isValid ? nil : "code_must_have_6_digits".localized
        
        self.codeBorderColor = {
            if sanitized.isEmpty {
                return UIColor.gray
            } else if isValid {
                return UIColor.systemGreen
            } else {
                return UIColor.systemRed
            }
        }()
    }
    
    func reset() {
        isCodeSent = false
        errorMessage = nil
        phoneErrorMessage = nil
        codeErrorMessage = nil
        isCodeValid = false
    }
    
    
}
