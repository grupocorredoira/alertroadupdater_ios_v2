import SwiftUI

struct NavGraph: View {
    @State private var currentScreen: Screen? = nil

    // Inicializar con los parámetros requeridos
    @StateObject private var prefs = PreferencesManager()
    @StateObject private var usersHandler = UsersHandler()
    @StateObject private var loginViewModel = LoginViewModel(usersHandler: UsersHandler(), prefs: PreferencesManager())
    @StateObject private var connectionViewModel = ConnectionViewModel(connectionManager: ConnectionManager(), documentsViewModel: <#T##DocumentsViewModel#>)
    @StateObject private var documentsViewModel = DocumentsViewModel(firestoreRepository: FirestoreRepository(), localRepository: LocalRepository())
    @StateObject private var uploadDocumentsViewModel = UploadDocumentsViewModel(localRepository: LocalRepository())

    // Repositorios y gestores requeridos
    @StateObject private var networkStatusRepository = NetworkStatusRepository()
    @StateObject private var connectionManager = ConnectionManager()
    @StateObject private var firestoreRepository = FirestoreRepository()
    @StateObject private var localRepository = LocalRepository()
    @StateObject private var networkStatusViewModel = NetworkStatusViewModel(networkStatusRepository: NetworkStatusRepository())

    var body: some View {
        NavigationView {
            VStack {
                getStartView()
                    .background(
                        NavigationLink(
                            destination: getDestinationView(for: currentScreen),
                            isActive: Binding(
                                get: { currentScreen != nil },
                                set: { if !$0 { currentScreen = nil } }
                            )
                        ) {
                            EmptyView()
                        }
                    )
            }
        }
    }

    /*
     @ViewBuilder
     private func getStartView() -> some View {
     let isTermsAccepted = prefs.getIsTermsAccepted()
     let isPrivacyAccepted = prefs.getIsPrivacyAccepted()
     let isAuthenticated = prefs.getIsAuthenticated()

     if !isTermsAccepted {
     TermsView(onAccept: { navigateTo(.privacyPolicies) })
     } else if !isPrivacyAccepted {
     PrivacyPolicyView(onAccept: { navigateTo(.login) })
     } else if isAuthenticated {
     WelcomeView(
     loginViewModel: loginViewModel,
     usersHandler: usersHandler
     )
     } else {
     LoginView(
     loginViewModel: loginViewModel,
     usersHandler: usersHandler,
     networkStatusViewModel: networkStatusViewModel,
     onLoginSuccess: { navigateTo(.welcome) }
     )
     }
     }*/

    @ViewBuilder
    private func getStartView() -> some View {
        // 🔹 Directamente empezamos en la pantalla de Welcome
        WelcomeView(
            loginViewModel: loginViewModel,
            usersHandler: usersHandler
        )
    }

    @ViewBuilder
    private func getDestinationView(for screen: Screen?) -> some View {
        switch screen {
            /*
             case .terms:
             TermsView(onAccept: { navigateTo(.privacyPolicies) })
             case .privacyPolicies:
             PrivacyPolicyView(onAccept: { navigateTo(.login) })
             case .login:
             LoginView(
             loginViewModel: loginViewModel,
             usersHandler: usersHandler,
             networkStatusViewModel: networkStatusViewModel,
             onLoginSuccess: { navigateTo(.welcome) }
             )

             case .verificationCode:
             VerifyCodeView(loginViewModel: loginViewModel)
             */
        case .welcome:
            WelcomeView(
                loginViewModel: loginViewModel,
                usersHandler: usersHandler
            )
        case .settings:
            SettingsView()
        case .connection:
            ConnectionScreen(
                connectionViewModel: connectionViewModel,
                documentsViewModel: documentsViewModel,
                networkStatusViewModel: networkStatusViewModel
            )
        case .upload(let deviceName):
            UploadView(
                connectionViewModel: connectionViewModel,
                documentsViewModel: documentsViewModel,
                uploadDocumentsViewModel: uploadDocumentsViewModel,
                deviceName: deviceName
            )
        case .none:
            EmptyView()
        }
    }

    private func navigateTo(_ screen: Screen) {
        currentScreen = screen
    }
}
