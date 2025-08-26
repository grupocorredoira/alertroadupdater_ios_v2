import UIKit
import SwiftUI

struct NetworkAlertManager {
    
    static func showNoInternetDialog() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "no_internet_title".localized,
            message: "no_internet_message".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "go_to_settings".localized, style: .default) { _ in
            ConnectionManager.shared.openWiFiSettings()
        })
        
        alert.addAction(UIAlertAction(title: "accept_button".localized, style: .cancel))
        
        rootVC.present(alert, animated: true)
    }
}
