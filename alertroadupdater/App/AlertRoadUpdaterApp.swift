import SwiftUI
import Firebase

@main
//He cambiado el nombre de alertroadupdaterApp a AlertRoadUpdaterApp
struct AlertRoadUpdaterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavGraph()
        }
    }
}
