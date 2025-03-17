import Foundation

enum Screen: String, CaseIterable, Identifiable {
    case terms
    case privacyPolicies
    case login
    case verificationCode
    case welcome
    case settings
    case connection
    case upload

    var id: String { self.rawValue }
}
