import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var showDialogSafeDisconnect = false
    @State private var showPrivacyPolicyDialog = false
    @State private var showTermsDialog = false
    @Binding var currentScreen: Screen?

    let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"

    var body: some View {
        VStack {
            Spacer()
            List {
                Section(header: Text("Preferencias de usuario").font(.headline)) {
                    SettingsOption(title: "Política de Privacidad") {
                        showPrivacyPolicyDialog = true
                    }
                    SettingsOption(title: "Términos y Condiciones") {
                        showTermsDialog = true
                    }
                    SettingsOption(title: "Eliminar archivos locales") {
                        deleteLocalFiles()
                    }
                    SettingsOption(title: "Cerrar sesión") {
                        showDialogSafeDisconnect = true
                    }
                }
            }

            Text("Versión: \(versionName) (\(versionCode))")
                .font(.footnote)
                .padding()
        }
        .overlay {
            if showDialogSafeDisconnect {
                disconnectDialog()
            }
        }
        // ✅ Ya no usamos .sheet ni NavigationView aquí
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }

    func deleteLocalFiles() {
        print("Archivos locales eliminados")
    }

    @ViewBuilder
    private func disconnectDialog() -> some View {
        VStack() {
            Text("¿Seguro que quieres cerrar sesión?")
                .font(.headline)
                .padding()

            Text("Para evitar problemas con tu cuenta, aconsejamos no cerrrar sesión, ¿estás seguro que deseas salir de tu cuenta?")
                .font(.subheadline)
                .padding()

            HStack(spacing: 12) {
                Button(action: {
                    signOut()
                    showDialogSafeDisconnect = false
                }) {
                    Text("Cerrar sesión")
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }

                Button(action: {
                    showDialogSafeDisconnect = false
                }) {
                    Text("Cancelar")
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
            }
            .padding()

        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Sesión cerrada correctamente")
            currentScreen = .login // 👈 Aquí es donde redirigimos al login
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}

struct SettingsOption: View {
    var title: String
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
