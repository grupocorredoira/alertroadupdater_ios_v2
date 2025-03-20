import SwiftUI

struct WelcomeView: View {
    //@ObservedObject var loginViewModel: LoginViewModel
    //@ObservedObject var usersHandler: UsersHandler
    @Binding var currentScreen: Screen? // Permite modificar la pantalla en NavGraph
    @State private var showPaymentDialog: Bool = false
    @State private var isCheckingUser: Bool = false
    @State private var snackbarMessage: String?

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
    }
}
