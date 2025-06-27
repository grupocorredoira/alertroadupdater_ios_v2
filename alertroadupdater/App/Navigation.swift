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

    @StateObject private var connectionManager = ConnectionManager()

    @StateObject private var documentsViewModel: DocumentsViewModel
    @StateObject private var uploadDocumentsViewModel: UploadDocumentsViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    @State private var connectionViewModel: ConnectionViewModel?

    @StateObject private var wifiSSIDManager = WiFiSSIDManager()
    @StateObject private var permissionsViewModel = PermissionsViewModel()



    private var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    init() {
        let firestoreRepo = FirestoreRepository()
        let documentsVM = DocumentsViewModel(firestoreRepository: firestoreRepo, localRepository: sharedLocalRepository)
        let uploadVM = UploadDocumentsViewModel(
            localRepository: sharedLocalRepository,
            documentsViewModel: documentsVM
        )
        let settingsVM = SettingsViewModel()

        _documentsViewModel = StateObject(wrappedValue: documentsVM)
        _uploadDocumentsViewModel = StateObject(wrappedValue: uploadVM)
        _settingsViewModel = StateObject(wrappedValue: settingsVM)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let screen = coordinator.current {
                    getDestinationView(for: screen)
                        .transition(.slide)
                } else {
                    getStartView()
                        .transition(.slide)
                }
            }
            .task {
                // Esto tiene que seguir este orden, porque si connectionViewModel no va primero, no cargará correctamente
                // la pantalla. Hay que poner los terminos para que siempre verifique y sino pregunte. El sleep es para que
                // a firebase le de tiempo al cargar
                if connectionViewModel == nil {
                    connectionViewModel = ConnectionViewModel(connectionManager: connectionManager)
                }

                guard prefs.getIsTermsAccepted(), prefs.getIsPrivacyAccepted() else {
                    print("⛔️ No se han aceptado términos o privacidad, no se navega")
                    return
                }

                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

                if isLoggedIn && coordinator.current == nil {
                    if prefs.getPhoneNumberWithPrefix().isEmpty,
                       let phone = Auth.auth().currentUser?.phoneNumber {
                        print("📲 Guardando número de teléfono: \(phone)")
                        prefs.savePhoneNumberWithPrefix(phone)
                    }

                    coordinator.navigate(to: .welcome)
                }
            }
        }
        .environmentObject(coordinator)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func getStartView() -> some View {
        if !prefs.getIsTermsAccepted() {
            TermsView(prefs: prefs)
        } else if !prefs.getIsPrivacyAccepted() {
            PrivacyPolicyView(prefs: prefs)
        } else if isLoggedIn {
            WelcomeView(
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel,
                documentsViewModel: documentsViewModel
            )
        } else {
            LoginView()
        }
    }


    // MARK: - Destinos
    @ViewBuilder
    private func getDestinationView(for screen: Screen) -> some View {
        switch screen {
        case .terms:
            TermsView(prefs: prefs)

        case .privacyPolicy:
            PrivacyPolicyView(prefs: prefs)

        case .login:
            LoginView()

        case .welcome:
            WelcomeView(
                wifiSSIDManager: wifiSSIDManager,
                permissionsViewModel: permissionsViewModel,
                documentsViewModel: documentsViewModel
            )

        case .settings:
            SettingsView(
                documentsViewModel: documentsViewModel,
                settingsViewModel: settingsViewModel)

        case .connection:
            if let connectionViewModel = connectionViewModel {
                ConnectionView(
                    title: "Conexión",
                    documentsViewModel: documentsViewModel,
                    connectionViewModel: connectionViewModel
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
enum Screen: Hashable {
    case terms
    case privacyPolicy
    case login
    case welcome
    case settings
    case connection
    case upload(deviceName: String)
}
