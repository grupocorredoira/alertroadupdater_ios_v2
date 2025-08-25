import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State var selectedPrefix: String = "+34"
    @EnvironmentObject var networkMonitorViewModel: NetworkMonitorViewModel
    @Environment(\.scenePhase) var scenePhase

    // Estado para el mensaje de error
    //@State private var errorMessage: String? = nil

    // 🔔 NUEVO: control del alert de “sin Internet”
    @State private var showNoInternetAlert: Bool = false

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

                    Text("login_title".localized)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("login_instructions".localized)
                        .font(.headline)
                        .bold()

                    CountryCodeDropdownMenu(
                        selectedPrefix: selectedPrefix,
                        onPrefixSelected: { newPrefix in
                            selectedPrefix = newPrefix
                        }
                    )

                    NumericTextFieldView(text: $loginViewModel.phoneNumber, placeholder: "phone_placeholder".localized, borderColor: loginViewModel.phoneBorderColor)
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
                        Text(loginViewModel.isLoading
                             ? "sending_sms".localized
                             : "login_button".localized)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(loginViewModel.accessButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!isPhoneNumberValid || loginViewModel.isLoading)

                } else {
                    Text("verification_instructions".localized)
                        .font(.headline)
                        .bold()


                    NumericCodeTextFieldView(
                        text: $loginViewModel.verificationCode,
                        placeholder: "sms_code_placeholder".localized,
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
                        ///TODO - mejorar en próxima refactorización
                        Text(LocalizedStringKey(
                            loginViewModel.isLoading ? "verifying_title" : "verify_button"
                        ))
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
        // 🔔 Se escucha el cambio de conectividad para lanzar el alert
        .onReceive(networkMonitorViewModel.$hasInternet.removeDuplicates()) { hasInternet in
            if !hasInternet {
                showNoInternetAlert = true
            }
        }
        // 🔔 Alert nativo
        .alert("no_internet_title".localized, isPresented: $showNoInternetAlert) {
            Button("accept_button".localized, role: .cancel) { }
        } message: {
            Text("no_internet_message".localized) // crea este string si no lo tienes
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                print("🔒 App en segundo plano, reseteando estado de login")
                loginViewModel.reset()
            }
        }
    }
}
