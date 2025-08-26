import SwiftUI

struct NotificationsPermissionBottomSheet: View {
    var isVisible: Bool
    var onDismiss: () -> Void
    var onGrantPermission: () -> Void
    var permissionMessage: String
    
    var body: some View {
        if isVisible {
            VStack {
                Text("notifications_permission_title".localized)
                    .font(.headline)
                    .padding()
                
                Text(permissionMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    onGrantPermission()
                    onDismiss()
                }) {
                    Text("grant_permission_button".localized)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: onDismiss) {
                    Text("cancel_button".localized)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
        }
    }
}
