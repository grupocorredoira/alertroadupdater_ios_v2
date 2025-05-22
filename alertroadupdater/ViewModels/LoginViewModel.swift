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
            return "Error de red, comprueba tu conexión a internet"
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
    
    func validatePhoneNumber(prefix: String) {
        let sanitized = phoneNumber.filter { $0.isNumber }
        
        let (isValid, errorMessage): (Bool, String?) = {
            switch prefix {
            case "+351", "+33":
                let valid = sanitized.count == 9
                return (valid, valid ? nil : "El número debe tener 9 dígitos")
                
            case "+34":
                let valid = sanitized.count == 9 && (sanitized.hasPrefix("6") || sanitized.hasPrefix("7"))
                if !valid {
                    if sanitized.count != 9 {
                        return (false, "El número móvil debe tener 9 dígitos")
                    } else {
                        return (false, "Con el prefijo +34 el teléfono debe comenzar con 6 o 7")
                    }
                }
                return (true, nil)
                
            default:
                let valid = sanitized.count >= 7
                return (valid, valid ? nil : "El número debe tener al menos 9 dígitos.")
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
        self.codeErrorMessage = isValid ? nil : "El código debe tener 6 dígitos"
        
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
    
}
