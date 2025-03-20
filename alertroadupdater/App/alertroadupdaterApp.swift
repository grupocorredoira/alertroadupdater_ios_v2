import SwiftUI
import Firebase

@main
struct alertroadupdaterApp: App {
/*
    init() {
        FirebaseApp.configure()
    }
*/
    var body: some Scene {
        WindowGroup {
            NavGraph()  // Aquí cargamos NavGraph en lugar de ConnectionView
        }
    }
}
