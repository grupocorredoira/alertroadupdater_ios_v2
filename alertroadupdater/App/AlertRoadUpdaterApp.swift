import SwiftUI
import Firebase
import StoreKit

@main
struct AlertRoadUpdaterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var purchaseService = PurchaseService.shared
    @StateObject var networkMonitor = NetworkMonitorViewModel()

    var body: some Scene {
        WindowGroup {
            NavGraph()
                .environmentObject(purchaseService)
                .environmentObject(networkMonitor)
                .onAppear {
                    // ✅ Inicia escucha manual de transacciones pendientes
                    Task {
                        await purchaseService.listenForPendingTransactions()
                    }
                }
        }
    }
}
