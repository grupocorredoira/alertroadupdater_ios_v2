import SwiftUI


struct SettingsView: View {
    @State private var showDialogSafeDisconnect = false
    @State private var showPrivacyPolicyDialog = false
    @State private var showTermsDialog = false

    let versionName = "1.0.0"
    let versionCode = "100"

    var body: some View {
        VStack {
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
        VStack {
            Text("¿Seguro que quieres cerrar sesión?")
                .font(.headline)
                .padding()

            HStack {
                Button("Cancelar") {
                    showDialogSafeDisconnect = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)

                Button("Sí, cerrar sesión") {
                    signOut()
                    showDialogSafeDisconnect = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    func signOut() {
        print("Sesión cerrada")
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
