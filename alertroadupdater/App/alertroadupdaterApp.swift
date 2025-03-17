//
//  alertroadupdaterApp.swift
//  alertroadupdater
//
//  Created by Corredoira on 17/3/25.
//

import SwiftUI
import Firebase

@main
struct alertroadupdaterApp: App {
  /*  var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
*/
    init() {
            FirebaseApp.configure()
        }

        var body: some Scene {
            WindowGroup {
                //WelcomeView()
                ConnectionView()
            }
        }
}
