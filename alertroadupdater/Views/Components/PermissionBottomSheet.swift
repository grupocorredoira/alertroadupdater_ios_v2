import SwiftUI

struct PermissionBottomSheet: View {
    var isVisible: Bool
    var onDismiss: () -> Void
    var onGrantPermission: () -> Void
    var permissionMessage: String

    var body: some View {
        if isVisible {
            VStack(spacing: 16) {
                Text("permission_required_title".localized)
                    .font(.headline)

                Text(permissionMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)

                Button("grant_permission_button".localized, action: {
                    onGrantPermission()
                    onDismiss()
                })
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("cancel_button".localized, action: onDismiss)
                    .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}
