import Foundation

enum Screen: Hashable/*, Identifiable*/ {
/*
    case terms
    case privacyPolicies
    case login
    case verificationCode
*/
    case login
    case welcome
    case settings
    case connection
    case upload(deviceName: String) // ✅ Ahora acepta un valor asociado

    /*
    var id: String {
        switch self {
        case .upload(let deviceName):
            return "upload_\(deviceName)" // Genera un ID único por dispositivo
        default:
            return "\(self)"
        }
    }
     */
}
