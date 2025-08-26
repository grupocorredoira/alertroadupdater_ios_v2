import Foundation
import UIKit
import SwiftUI

class Utils {
    
    /// Muestra un `Toast` con el mensaje y duración especificados.
    static func showToast(message: String, duration: ToastLength) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let toastLabel = UILabel(frame: CGRect(x: window.frame.width / 2 - 100,
                                               y: window.frame.height - 100,
                                               width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        window.addSubview(toastLabel)
        
        UIView.animate(withDuration: duration.value, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    /// Obtiene el `versionName` de la aplicación.
    static func getVersionName() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    /// Obtiene el `versionCode` (build number) de la aplicación.
    static func getVersionCode() -> Int {
        return Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-1") ?? -1
    }
    /*
     /// Reporta errores en `Firebase Crashlytics`.
     static func reportCrash(className: String, errorMessage: String) {
     let errorInfo = "Clase: \(className) - Error: \(errorMessage)"
     print(errorInfo)
     
     let exception = NSError(domain: className, code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
     
     Crashlytics.crashlytics().setCustomValue(className, forKey: "Clase")
     Crashlytics.crashlytics().setCustomValue(errorMessage, forKey: "Mensaje de error")
     Crashlytics.crashlytics().record(error: exception)
     }
     */
}

/// Enum para la duración del Toast
enum ToastLength {
    case short, long
    
    var value: TimeInterval {
        switch self {
        case .short: return 2.0
        case .long: return 4.0
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}


