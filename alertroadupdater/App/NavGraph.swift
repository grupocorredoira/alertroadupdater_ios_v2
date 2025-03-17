import SwiftUI
/*
struct NavGraph: View {
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            getStartView()
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .terms:
                        TermsView(onAccept: { navigateTo(.privacyPolicies) })
                    case .privacyPolicies:
                        PrivacyPolicyView(onAccept: { navigateTo(.login) })
                    case .login:
                        LoginView(onLoginSuccess: { navigateTo(.welcome) })
                    case .verificationCode:
                        VerifyCodeView()
                    case .welcome:
                        WelcomeView()
                    case .settings:
                        SettingsView()
                    case .connection:
                        ConnectionView()
                    case .upload:
                        UploadView(deviceName: "TestDevice") // Aquí se manejaría el parámetro dinámico
                    }
                }
        }
    }

    // Función para definir la pantalla inicial
    @ViewBuilder
    private func getStartView() -> some View {
        let isTermsAccepted = UserDefaults.standard.bool(forKey: "isTermsAccepted")
        let isPrivacyAccepted = UserDefaults.standard.bool(forKey: "isPrivacyAccepted")
        let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")

        if !isTermsAccepted {
            TermsView(onAccept: { navigateTo(.privacyPolicies) })
        } else if !isPrivacyAccepted {
            PrivacyPolicyView(onAccept: { navigateTo(.login) })
        } else if isAuthenticated {
            WelcomeView()
        } else {
            LoginView(onLoginSuccess: { navigateTo(.welcome) })
        }
    }

    // Función para manejar la navegación
    private func navigateTo(_ screen: Screen) {
        path.append(screen)
    }
}*/
