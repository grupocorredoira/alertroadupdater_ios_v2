/*import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var usersHandler: UsersHandler
    @ObservedObject var networkStatusViewModel: NetworkStatusViewModel
    var onLoginSuccess: () -> Void

    @State private var selectedPrefix: String = "+34"
    @State private var phoneNumber: String = ""
    @State private var isCheckingUser = false
    @State private var showVerificationScreen = false

    var phoneNumberWithPrefix: String {
        return "\(selectedPrefix)\(phoneNumber)"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Barra superior con logo
                TopAppBarComponentWithLogo(showMenu: false)

                Spacer()

                Text("Iniciar sesión")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Introduce tu número de teléfono para verificar tu cuenta.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                CountryCodeDropdownMenu(
                    selectedPrefix: selectedPrefix,
                    onPrefixSelected: { prefix in
                        selectedPrefix = prefix
                    }
                )

                TextField("Número de teléfono", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onChange(of: phoneNumber) { _ in
                        loginViewModel.validatePhoneNumber(prefix: selectedPrefix, phone: phoneNumber)
                    }

                if let errorMessage = loginViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if networkStatusViewModel.hasInternet {
                    Button(action: handleLogin) {
                        Text("Iniciar sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(loginViewModel.isPhoneValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!loginViewModel.isPhoneValid)
                } else {
                    Text("No tienes conexión a Internet.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                NavigationLink(destination: VerifyCodeView(loginViewModel: loginViewModel), isActive: $showVerificationScreen) {
                    EmptyView()
                }
            }
            .padding()
            .overlay {
                if isCheckingUser {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack {
                                ProgressView("Verificando cuenta...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                            }
                        )
                }
            }
        }
    }

    private func handleLogin() {
        isCheckingUser = true
        let currentUser = Auth.auth().currentUser

        if let currentUser = currentUser, currentUser.phoneNumber == phoneNumberWithPrefix {
            // Usuario autenticado y número coincide
            PreferencesManager.shared.savePhoneNumberWithPrefix(phoneNumberWithPrefix) // ✅ Guardar número en preferencias
            isCheckingUser = false
            onLoginSuccess()
        } else {
            // Si hay sesión pero el número no coincide, cerrar sesión
            if currentUser != nil {
                loginViewModel.signOut()
            }
            // Proceder con verificación SMS
            loginViewModel.sendVerificationCode(phoneNumber: phoneNumberWithPrefix)
            isCheckingUser = false
            showVerificationScreen = true
        }
    }
}
*/
