import SwiftUI

struct PrivacyPolicyView: View {
    var onAccept: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                // Barra superior con logo
                TopAppBarComponentWithLogo(showMenu: false)

                Text("Política de Privacidad")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                ScrollView {
                    Text("""
                    Aquí va el contenido de la política de privacidad. Puedes cargarlo desde un archivo o una cadena larga.
                    """)
                    .font(.body)
                    .padding()
                }

                Button(action: onAccept) {
                    Text("Aceptar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
}
