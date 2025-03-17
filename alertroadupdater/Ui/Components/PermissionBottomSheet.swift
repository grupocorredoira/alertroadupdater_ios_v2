import SwiftUI

struct PermissionBottomSheet: View {
    var isVisible: Bool
    var onDismiss: () -> Void
    var onGrantPermission: () -> Void
    var permissionMessage: String

    var body: some View {
        if isVisible {
            VStack(spacing: 16) {
                Text("Se requiere permiso")
                    .font(.headline)

                Text(permissionMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)

                Button("Conceder Permiso", action: {
                    onGrantPermission()
                    onDismiss()
                })
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Cancelar", action: onDismiss)
                    .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}
