import SwiftUI

struct TopAppBarComponentWithLogo: View {
    var logoName: String = "logo_cabecera" // Reemplaza con el nombre de tu imagen en Assets
    var showMenu: Bool = true
    var onMenuClick: () -> Void = {}

    var body: some View {
        HStack {
            Spacer()
            Image(logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 40) // Ajusta el tamaño del logo
            Spacer()

            if showMenu {
                Button(action: onMenuClick) {
                    Image(systemName: "line.horizontal.3") // Icono de menú en SF Symbols
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color.black) // Color de fondo
    }
}
