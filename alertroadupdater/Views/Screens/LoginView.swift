import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State var selectedPrefix: String = "+34"
    @EnvironmentObject var networkMonitorViewModel: NetworkMonitorViewModel
    @Environment(\.scenePhase) var scenePhase

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
            TopAppBarViewWithLogo()

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

                        NumericTextFieldView(text: $loginViewModel.phoneNumber, placeholder: "Introduce tu número", borderColor: loginViewModel.phoneBorderColor)
                            .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                            .onChange(of: loginViewModel.phoneNumber) { _ in
                                loginViewModel.validatePhoneNumber(prefix: selectedPrefix)
                            }

                        if let phoneError = loginViewModel.phoneErrorMessage {
                            Text(phoneError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .padding(.horizontal)
                        }

                        Button(action: {
                            guard networkMonitorViewModel.hasInternet else {
                                NetworkAlertManager.showNoInternetDialog()
                                return
                            }

                            let fullNumber = "\(selectedPrefix)\(loginViewModel.phoneNumber)"

                            if Auth.auth().currentUser != nil {
                                print("✅ Usuario ya autenticado, navegando directamente")
                                coordinator.navigate(to: .welcome)
                            } else {
                                print("✅ Usuario NO autenticado")
                                loginViewModel.sendVerificationCode(to: fullNumber)
                            }
                        }) {
                            Text(loginViewModel.isLoading ? "Enviando SMS..." : "Acceder")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(loginViewModel.accessButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!isPhoneNumberValid || loginViewModel.isLoading)

                    } else {
                        Text("Te vamos a enviar un SMS. A continuación, introduce el código de verificación que aparece en el mensaje:")
                            .font(.headline)
                            .bold()


                        NumericCodeTextFieldView(
                            text: $loginViewModel.verificationCode,
                            placeholder: "Código SMS",
                            borderColor: loginViewModel.codeBorderColor
                        )
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                        .onChange(of: loginViewModel.verificationCode) { _ in
                            loginViewModel.validateVerificationCode()
                        }

                        if let codeError = loginViewModel.codeErrorMessage {
                            Text(codeError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .padding(.horizontal)
                        }

                        Button(action: {
                            loginViewModel.verifyCode {
                                coordinator.navigate(to: .welcome)
                            }
                        }) {
                            Text(loginViewModel.isLoading ? "Verificando..." : "Verificar")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(loginViewModel.verifyButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!loginViewModel.canVerify)
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
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                print("🔒 App en segundo plano, reseteando estado de login")
                loginViewModel.reset()
            }
        }
    }
}
