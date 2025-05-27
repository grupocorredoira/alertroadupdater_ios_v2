import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white) // ✅ Flecha blanca
                        .padding(8)
                        .background(Circle().fill(Color.gray.opacity(0.3))) // ✅ Círculo gris
                }
                .padding(.leading)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white) // ✅ Texto blanco
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if showBackButton {
                Spacer().frame(width: 44)
            }
        }
        .frame(maxWidth: .infinity) // ✅ Esto garantiza que ocupe todo el ancho
        .background(Color(.black))
        .foregroundColor(.primary)
    }
}
