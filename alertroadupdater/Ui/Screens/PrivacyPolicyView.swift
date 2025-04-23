import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @ObservedObject var prefs: PreferencesManager

    var body: some View {
        VStack(spacing: 16) {
            TopAppBarComponentWithLogo()

            Spacer()

            Text("Política de privacidad")
                .font(.title)
                .bold()
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {


                    Text("Aquí va el contenido completo de la política de privacidad...")

                    Button("Aceptar") {
                        prefs.savePrivacyAccepted(true)
                        coordinator.navigate(to: .login)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
                .padding()
            }
        }
    }
}

struct PrivacyDialogView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Política de Privacidad")
                .font(.headline)
                .padding(.top)

            ScrollView {
                Text("""
                Aquí va el contenido completo de la política de privacidad de la aplicación...
                """)
                    .font(.body)
                    .padding()
            }

            Button("Cerrar") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 350, maxHeight: 500)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
