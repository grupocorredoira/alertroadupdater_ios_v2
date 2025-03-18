import SwiftUI
/*
struct VerifyCodeView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var insertedCode: String = ""
    @State private var isVerifying: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                TopAppBarComponent(title: "Verificación") {
                    presentationMode.wrappedValue.dismiss()
                }

                Spacer()

                Text("Introduce el código de verificación enviado a tu número de teléfono.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                VerifyCodeInputComponent(onCodeComplete: { code in
                    insertedCode = code
                })
                .padding(.vertical, 16)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.bottom, 8)
                }

                Button(action: {
                    isVerifying = true
                    loginViewModel.verifyCode(insertedCode) { success, error in
                        isVerifying = false
                        if success {
                            // Navegar a la pantalla de bienvenida
                            loginViewModel.isAuthenticated = true
                        } else {
                            errorMessage = error
                        }
                    }
                }) {
                    Text("Verificar código")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(insertedCode.count == 6 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .disabled(insertedCode.count != 6)

                if isVerifying {
                    ProgressView("Verificando...")
                        .padding(.top, 16)
                }

                Spacer()

                SmsResendSection {
                    loginViewModel.resendCode()
                }
                .padding(.bottom, 16)
            }
            .padding()
            .onAppear {
                loginViewModel.clearError()
            }
        }
        .navigationDestination(isPresented: $loginViewModel.isAuthenticated) {
            WelcomeView()
        }
    }
}
*/
