import SwiftUI
import CoreLocation

struct WelcomeView: View {
    //@ObservedObject var loginViewModel: LoginViewModel
    //@ObservedObject var usersHandler: UsersHandler
    @Binding var currentScreen: Screen? // Permite modificar la pantalla en NavGraph
    @State private var showPaymentDialog: Bool = false
    @State private var isCheckingUser: Bool = false
    @State private var snackbarMessage: String?
    @ObservedObject var wifiSSIDManager: WiFiSSIDManager
    @State private var showPermissionDenied = false
    @ObservedObject var permissionsViewModel: PermissionsViewModel // ✅ ESTA ES LA BUENA


    var body: some View {
        VStack(spacing: 16) {
            // Barra de navegación arriba del todo
            TopAppBarComponentWithLogo(
                showMenu: true,
                onMenuClick: { currentScreen = .settings } // Navegar a la configuración
            )

            Spacer()

            Text("¡Bienvenido!")
                .font(.largeTitle)
                .bold()

            Text("Número registrado: \(PreferencesManager.shared.getPhoneNumberWithPrefix())")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Button(action: {
                handleStartButtonTap()
                isCheckingUser = true
                currentScreen = .connection
/*
                Task {
                    let userIsAuthenticated = await usersHandler.checkUserIsAuthenticated(
                        phoneNumber: PreferencesManager.shared.getPhoneNumberWithPrefix()
                    )

                    if userIsAuthenticated {
                        if let user = await usersHandler.getUser(
                            phoneNumber: PreferencesManager.shared.getPhoneNumberWithPrefix()
                        ) {
                            if usersHandler.checkHaveToPurchase(user: user) {
                                isCheckingUser = false
                                showPaymentDialog = true
                            } else {
                                // Navegar a la pantalla de conexión
                                loginViewModel.isAuthenticated = true
                                currentScreen = .connection
                            }
                        } else {
                            isCheckingUser = false
                            snackbarMessage = "Error obteniendo usuario"
                        }
                    } else {
                        isCheckingUser = false
                        snackbarMessage = "Error de autenticación"
                    }
                }
                */
            }) {
                Text("Empezar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.top, 0) // Elimina cualquier margen superior
        .ignoresSafeArea(edges: .top) // Se asegura que la barra esté pegada arriba
        .padding(.top, 0)
                .ignoresSafeArea(edges: .top)
                .alert(isPresented: $showPermissionDenied) {
                    Alert(title: Text("Permisos requeridos"),
                          message: Text("Debes permitir acceso a la localización para detectar la red Wi-Fi."),
                          dismissButton: .default(Text("Aceptar")))
                }
                .onAppear {
                    wifiSSIDManager.requestLocationPermission()
                }
    }

    private func handleStartButtonTap() {
            let status = CLLocationManager.authorizationStatus()

            if status == .authorizedWhenInUse || status == .authorizedAlways {
                currentScreen = .connection
            } else if status == .notDetermined {
                permissionsViewModel.checkPermissions()

                // Escucha el cambio de permisos en segundo plano
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if permissionsViewModel.hasLocationPermission {
                        currentScreen = .connection
                    } else {
                        snackbarMessage = "Se necesitan permisos de ubicación para continuar"
                    }
                }
            } else {
                snackbarMessage = "Se necesitan permisos de ubicación para continuar"
            }
        }
}
