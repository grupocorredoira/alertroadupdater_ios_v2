import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State var selectedPrefix: String = "+34"

    var body: some View {
        VStack(spacing: 0) {
            TopAppBarComponentWithLogo()

            Spacer()

            VStack(spacing: 24) {

                if !loginViewModel.isCodeSent {

                    Text("Accede a tu cuenta")
                        .font(.largeTitle)
                        .bold()

                    Text("Si no tienes una cuenta creada, al introducir tu teléfono móvil te enviaremos un SMS para registrarte")
                        .font(.headline)
                        .bold()

                    // Dropdown para seleccionar el prefijo
                    CountryCodeDropdownMenu(
                        selectedPrefix: selectedPrefix,
                        onPrefixSelected: { newPrefix in
                            selectedPrefix = newPrefix
                        }
                    )

                    //Recojo el phone number, pero luego paso el fullnumber
                    TextField("Introduce tu número", text: $loginViewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    Button(action: {
                        let fullNumber = "\(selectedPrefix)\(loginViewModel.phoneNumber)"

                        // ✅ Primero verifica si ya está autenticado con Firebase
                        if Auth.auth().currentUser != nil {
                            print("✅ Usuario ya autenticado, navegando directamente")
                            coordinator.navigate(to: .welcome)
                        } else {
                            // Si no está autenticado, sigue el flujo habitual
                            print("✅ Usuario NO autenticado")
                            loginViewModel.sendVerificationCode(to: fullNumber)
                        }
                    }) {
                        Text("Entrar")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(loginViewModel.isLoading)

                } else {
                    TextField("Código SMS", text: $loginViewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    Button(action: {
                        loginViewModel.verifyCode {
                            coordinator.navigate(to: .welcome)
                        }
                    }) {
                        Text("Verificar")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(loginViewModel.isLoading)
                }

                if let errorMessage = loginViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: errorMessage)
                }

            }
            .padding() // 👉 Aquí el padding horizontal para todo el contenido
            .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            Spacer()
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
    }
}
