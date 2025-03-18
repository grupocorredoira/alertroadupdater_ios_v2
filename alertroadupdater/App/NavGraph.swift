import SwiftUI

struct NavGraph: View {
    @State private var currentScreen: Screen? = nil

    // Inicializar con los parámetros requeridos
    @StateObject private var prefs = PreferencesManager()
    @StateObject private var usersHandler = UsersHandler()
    @StateObject private var loginViewModel = LoginViewModel(usersHandler: UsersHandler(), prefs: PreferencesManager())

    // Crear una instancia de ConnectionManager
    @StateObject private var connectionManager = ConnectionManager()

    // Repositorios y gestores requeridos
    @StateObject private var documentsViewModel = DocumentsViewModel(firestoreRepository: FirestoreRepository(), localRepository: LocalRepository())
    @StateObject private var uploadDocumentsViewModel = UploadDocumentsViewModel(localRepository: LocalRepository())
    @StateObject private var networkStatusRepository = NetworkStatusRepository()
    @StateObject private var firestoreRepository = FirestoreRepository()
    @StateObject private var localRepository = LocalRepository()
    @StateObject private var networkStatusViewModel = NetworkStatusViewModel(networkStatusRepository: NetworkStatusRepository())

    @State private var connectionViewModel: ConnectionViewModel?

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
            .onAppear {
                // Inicializa connectionViewModel aquí
                if connectionViewModel == nil {
                    connectionViewModel = ConnectionViewModel(connectionManager: connectionManager)
                }
            }
        }
    }

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
        case .welcome:
            WelcomeView(
                loginViewModel: loginViewModel,
                usersHandler: usersHandler
            )
        case .settings:
            SettingsView()
        case .connection:
            if let connectionViewModel = connectionViewModel {
                ConnectionScreen(
                    connectionViewModel: connectionViewModel,
                    documentsViewModel: documentsViewModel,
                    networkStatusViewModel: networkStatusViewModel
                )
            }
        case .upload(let deviceName):
            UploadView(
                connectionViewModel: connectionViewModel!,
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
