import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let tokenLogin = "tokenLogin"
        static let isAuthenticated = "isAuthenticated"
        static let phoneNumberWithPrefix = "phoneNumberWithPrefix"
        static let termsAccepted = "termsAccepted"
        static let privacyAccepted = "privacyAccepted"
    }
    
    func saveTokenLogin(_ token: String) {
        userDefaults.set(token, forKey: Keys.tokenLogin)
    }
    
    func getTokenLogin() -> String {
        return userDefaults.string(forKey: Keys.tokenLogin) ?? ""
    }
    
    func saveIsAuthenticated(_ isAuthenticated: Bool) {
        userDefaults.set(isAuthenticated, forKey: Keys.isAuthenticated)
    }
    
    func getIsAuthenticated() -> Bool {
        return userDefaults.bool(forKey: Keys.isAuthenticated)
    }
    
    func savePhoneNumberWithPrefix(_ phoneNumber: String) {
        userDefaults.set(phoneNumber, forKey: Keys.phoneNumberWithPrefix)
    }
    
    func getPhoneNumberWithPrefix() -> String {
        return userDefaults.string(forKey: Keys.phoneNumberWithPrefix) ?? ""
    }
    
    func saveTermsAccepted(_ accepted: Bool) {
        userDefaults.set(accepted, forKey: Keys.termsAccepted)
    }
    
    func getIsTermsAccepted() -> Bool {
        return userDefaults.bool(forKey: Keys.termsAccepted)
    }
    
    func savePrivacyAccepted(_ accepted: Bool) {
        userDefaults.set(accepted, forKey: Keys.privacyAccepted)
    }
    
    func getIsPrivacyAccepted() -> Bool {
        return userDefaults.bool(forKey: Keys.privacyAccepted)
    }
    
    func clear(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        let keys = [
            Keys.tokenLogin,
            Keys.isAuthenticated,
            Keys.phoneNumberWithPrefix,
            Keys.termsAccepted,
            Keys.privacyAccepted
        ]
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
