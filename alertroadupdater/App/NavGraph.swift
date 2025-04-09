import SwiftUI
import FirebaseAuth

struct NavGraph: View {
    @State private var currentScreen: Screen? = nil

    // ✅ Instancia única y compartida
    private let sharedLocalRepository = LocalRepository()

    @StateObject private var prefs = PreferencesManager()
    /*
     @StateObject private var usersHandler = UsersHandler()
     @StateObject private var loginViewModel = LoginViewModel(usersHandler: UsersHandler(), prefs: PreferencesManager())
     */
    // Crear una instancia de ConnectionManager
    @StateObject private var connectionManager = ConnectionManager()

    // Repositorios y gestores requeridos
    @StateObject private var documentsViewModel: DocumentsViewModel
    @StateObject private var uploadDocumentsViewModel: UploadDocumentsViewModel

    /*
     @StateObject private var firestoreRepository = FirestoreRepository()
     */
    @StateObject private var networkStatusRepository = NetworkStatusRepository()

    @StateObject private var networkStatusViewModel = NetworkStatusViewModel(networkStatusRepository: NetworkStatusRepository())

    @State private var connectionViewModel: ConnectionViewModel?

    // 👇 Añadimos estos dos
    @StateObject private var wifiSSIDManager = WiFiSSIDManager()
    @StateObject private var permissionsViewModel = PermissionsViewModel()

    private var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }


    init() {
        // ✅ Inicializa manualmente los StateObjects con la misma instancia
        let firestoreRepo = FirestoreRepository()
        let documentsVM = DocumentsViewModel(firestoreRepository: firestoreRepo, localRepository: sharedLocalRepository)
        let uploadVM = UploadDocumentsViewModel(
            localRepository: sharedLocalRepository,
            documentsViewModel: documentsVM // 👈 añadido
        )


        _documentsViewModel = StateObject(wrappedValue: documentsVM)
        _uploadDocumentsViewModel = StateObject(wrappedValue: uploadVM)
    }



    var body: some View {
        NavigationView {
            ZStack {
                getStartView()

                NavigationLink(
                    destination: currentScreen.map { screen in
                        getDestinationView(for: screen)
                    },
                    isActive: Binding(
                        get: { currentScreen != nil },
                        set: { if !$0 { currentScreen = nil } }
                    )
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Atrás") // ✅ Agrega un título para evitar conflictos
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if connectionViewModel == nil {
                    connectionViewModel = ConnectionViewModel(connectionManager: connectionManager)
                }
            }
        }
    }

    @ViewBuilder
    private func getStartView() -> some View {
        if isLoggedIn {
            WelcomeView(
                currentScreen: $currentScreen,
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel
            )
        } else {
            LoginView(currentScreen: $currentScreen)
        }
    }


    @ViewBuilder
    private func getDestinationView(for screen: Screen) -> some View {
        switch screen {
        case .login:
            LoginView(
                currentScreen: $currentScreen
            )
        case .welcome:
            WelcomeView(
                currentScreen: $currentScreen,
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel
            )
        case .settings:
            SettingsView(currentScreen: $currentScreen)
        case .connection:
            if let connectionViewModel = connectionViewModel {
                ConnectionView(
                    title: "Conexión",
                    documentsViewModel: documentsViewModel,
                    connectionViewModel: connectionViewModel,
                    networkStatusViewModel: networkStatusViewModel
                ) { deviceName in
                    // ✅ Cuando se selecciona una red, se navega a UploadView con el SSID
                    currentScreen = .upload(deviceName: deviceName)
                }
            }
        case .upload(let deviceName):
            UploadView(deviceName: deviceName, documentsViewModel: documentsViewModel, uploadDocumentsViewModel: uploadDocumentsViewModel, wifiSSIDManager: wifiSSIDManager, currentScreen: $currentScreen)
        }
    }


    private func navigateTo(_ screen: Screen) {
        currentScreen = screen
    }
}
