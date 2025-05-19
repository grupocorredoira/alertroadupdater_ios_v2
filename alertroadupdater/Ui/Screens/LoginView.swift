import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State var selectedPrefix: String = "+34"
    
    // Estado para el mensaje de error
    @State private var errorMessage: String? = nil
    
    var isPhoneNumberValid: Bool {
        return loginViewModel.phoneNumber.count == 9
    }
    
    var shouldShowLengthError: Bool {
        return !loginViewModel.phoneNumber.isEmpty && loginViewModel.phoneNumber.count < 9
    }
    
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

                    CountryCodeDropdownMenu(
                        selectedPrefix: selectedPrefix,
                        onPrefixSelected: { newPrefix in
                            selectedPrefix = newPrefix
                        }
                    )
                    
                    NumericTextFieldView(text: $loginViewModel.phoneNumber, placeholder: "Introduce tu número")
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                        .onChange(of: loginViewModel.phoneNumber) { newValue in
                            if !newValue.isEmpty && newValue.count < 9 {
                                errorMessage = "El número debe tener 9 dígitos."
                            } else {
                                errorMessage = nil
                            }
                        }
                    
                    if shouldShowLengthError {
                        Text(errorMessage ?? "")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        let fullNumber = "\(selectedPrefix)\(loginViewModel.phoneNumber)"

                        if Auth.auth().currentUser != nil {
                            print("✅ Usuario ya autenticado, navegando directamente")
                            coordinator.navigate(to: .welcome)
                        } else {
                            print("✅ Usuario NO autenticado")
                            loginViewModel.sendVerificationCode(to: fullNumber)
                        }
                    }){
                        Text("Entrar")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isPhoneNumberValid || loginViewModel.isLoading)
                    .background(isPhoneNumberValid ? Color.blue : Color.gray.opacity(0.4))
                    
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
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            Spacer()
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
        .hideKeyboardOnTap()
    }
}
