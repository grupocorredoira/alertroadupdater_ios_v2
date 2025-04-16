import SwiftUI
import FirebaseAuth


// MARK: - Coordinador de navegación (permite push, popTo y reset)
class NavigationCoordinator: ObservableObject {
    @Published var path: [Screen] = [] {
        didSet {
            print("🧭 Stack actual:", path)
        }
    }

    func navigate(to screen: Screen) {
        path.append(screen)
        print("➡️ navigate(to: \(screen))")
    }

    func pop() {
        let removed = path.popLast()
        print("⬅️ pop() → \(removed ?? .login)")
    }

    func popTo(_ screen: Screen) {
        if let index = path.firstIndex(of: screen) {
            path = Array(path.prefix(upTo: index + 1))
            print("⬅️ popTo(\(screen))")
        } else {
            print("⚠️ popTo(\(screen)) falló: no está en el stack")
        }
    }

    func reset() {
        print("🔄 reset()")
        path = []
    }

    func pushIfNeeded(_ screen: Screen) {
        if !path.contains(screen) {
            print("🆕 pushIfNeeded(\(screen)) desde: \(Thread.callStackSymbols.joined(separator: "\n"))")
            path.append(screen)
        } else {
            print("⏩ pushIfNeeded ignorado, ya estaba en el stack: \(screen)")
        }
    }

    var current: Screen? {
        path.last
    }
}

struct NavGraph: View {
    @StateObject private var coordinator = NavigationCoordinator()

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

    @State private var isActive: Bool = false
    @State private var destination: Screen? = nil

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
                    destination: destination.map { getDestinationView(for: $0) },
                    isActive: Binding(
                        get: { destination != nil },
                        set: { isActive in
                            if !isActive {
                                coordinator.pop()
                                destination = coordinator.current
                            }
                        }
                    )
                ) {
                    EmptyView()
                }
            }
            .onReceive(coordinator.$path) { path in
                destination = path.last
                isActive = path.last != nil
            }
            .onAppear {
                if connectionViewModel == nil {
                    connectionViewModel = ConnectionViewModel(connectionManager: connectionManager)
                }
            }
        }
        .environmentObject(coordinator)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Pantalla inicial
    @ViewBuilder
    private func getStartView() -> some View {
        if isLoggedIn {
            WelcomeView(
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel
            )
        }
        else {
            LoginView()
        }
    }

    // MARK: - Destinos
    @ViewBuilder
    private func getDestinationView(for screen: Screen) -> some View {
        switch screen {
        case .login:
            LoginView()
        case .welcome:
            WelcomeView(
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel
            )
        case .settings:
            SettingsView()
        case .connection:
            // connectionViewModel no se puede inicializar como StateObject, al inicializarse como State
            // está inicializada en el onAppear, por seguridad en
            if let connectionViewModel = connectionViewModel {
                ConnectionView(
                    title: "Conexión",
                    documentsViewModel: documentsViewModel,
                    connectionViewModel: connectionViewModel,
                    networkStatusViewModel: networkStatusViewModel
                ) { deviceName in
                    coordinator.navigate(to: .upload(deviceName: deviceName))
                }
            }
        case .upload(let deviceName):
            UploadView(
                deviceName: deviceName,
                documentsViewModel: documentsViewModel,
                uploadDocumentsViewModel: uploadDocumentsViewModel,
                wifiSSIDManager: wifiSSIDManager
            )
        }
    }
}

// MARK: - Rutas de navegación tipo NavGraph
enum Screen: Hashable/*, Identifiable*/ {
    /*
     case terms
     case privacyPolicies
     */
    case login
    case welcome
    case settings
    case connection
    case upload(deviceName: String) // ✅ Ahora acepta un valor asociado
}
