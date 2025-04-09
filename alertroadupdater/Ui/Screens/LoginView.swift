import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Binding var currentScreen: Screen?

    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.isCodeSent {
                TextField("Introduce tu número", text: $viewModel.phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: {
                    viewModel.checkIfPhoneExists {
                        currentScreen = .welcome
                    }
                }) {
                    Text("Continuar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
            } else {
                TextField("Código SMS", text: $viewModel.verificationCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: {
                    viewModel.verifyCode {
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
                .disabled(viewModel.isLoading)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
