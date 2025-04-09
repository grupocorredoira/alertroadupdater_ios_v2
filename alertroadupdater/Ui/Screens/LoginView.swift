import SwiftUI

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @Binding var currentScreen: Screen?
    @State var selectedPrefix: String = "+34"

    var body: some View {
        VStack(spacing: 16) {
            TopAppBarComponentWithLogo()

            Spacer()

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
                    loginViewModel.checkIfPhoneExists(fullPhoneNumber: fullNumber) {
                        currentScreen = .welcome
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
                        currentScreen = .welcome
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
            }

            Spacer()
            Spacer()
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
    }
}
