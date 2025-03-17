import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    @State private var selectedPrefix: String = "+34"
    @State private var phoneNumber: String = ""
    @State private var isCheckingUser = false

    var phoneNumberWithPrefix: String {
        return "\(selectedPrefix)\(phoneNumber)"
    }

    var body: some View {
        NavigationStack {
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
                        viewModel.validatePhoneNumber(selectedPrefix, phoneNumber)
                    }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if viewModel.isInternetAvailable {
                    Button(action: handleLogin) {
                        Text("Iniciar sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isPhoneValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.isPhoneValid)
                } else {
                    Text("No tienes conexión a Internet.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .overlay {
                if isCheckingUser {
                    ProgressView("Verificando cuenta...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }

    private func handleLogin() {
        isCheckingUser = true
        let currentUser = Auth.auth().currentUser

        if let currentUser = currentUser, currentUser.phoneNumber == phoneNumberWithPrefix {
            // Usuario autenticado y número coincide
            viewModel.savePhoneNumber(phoneNumberWithPrefix)
            isCheckingUser = false
            viewModel.navigateToWelcome()
        } else {
            // Si hay sesión pero el número no coincide, cerrar sesión
            if currentUser != nil {
                viewModel.signOut()
            }
            // Proceder con verificación SMS
            viewModel.sendVerificationCode(phoneNumberWithPrefix)
            isCheckingUser = false
            viewModel.navigateToVerification()
        }
    }
}
