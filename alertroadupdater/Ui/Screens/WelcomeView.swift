import SwiftUI

struct WelcomeView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var usersHandler: UsersHandler
    @State private var showPaymentDialog: Bool = false
    @State private var isCheckingUser: Bool = false
    @State private var snackbarMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                TopAppBarComponentWithLogo(
                    showMenu: true,
                    onMenuClick: { /* Navegar a la configuración */ }
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
            .padding()
            // TODO: revisar pagos y paso a siguiente pantalla
            /*.alert(item: $snackbarMessage) { message in
                Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("Aceptar")))
            }
            .sheet(isPresented: $showPaymentDialog) {
                PurchaseDialog(isPresented: $showPaymentDialog)
            }
            .overlay {
                if isCheckingUser {
                    LoadingDialog()
                }
            }*/

            /*.navigationDestination(isPresented: $loginViewModel.isAuthenticated) {
                ConnectionView(
                    connectionViewModel: connectionViewModel,
                    documentsViewModel: documentsViewModel,
                    networkStatusViewModel: networkStatusViewModel
                )
            }*/
        }
    }
}

struct PurchaseDialog: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Acceso Requerido")
                .font(.title)
                .padding()

            Text("Para continuar, necesitas completar una compra.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Comprar") {
                // Iniciar el flujo de compra
                isPresented = false
            }
            .padding()

            Button("Cancelar") {
                isPresented = false
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

struct LoadingDialog: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Iniciando...")
                .font(.body)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
