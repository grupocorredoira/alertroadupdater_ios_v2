import SwiftUI

struct DialogReadTextComponent: View {
    var showDialog: Bool
    var title: String
    var text: String
    var onDismiss: () -> Void

    var body: some View {
        if showDialog {
            VStack {
                Text(title)
                    .font(.headline)
                    .bold()
                ScrollView {
                    Text(text)
                        .font(.body)
                        .padding()
                }
                .frame(height: 300)

                Button("Aceptar", action: onDismiss)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}
