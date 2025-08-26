import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @ObservedObject var prefs: PreferencesManager
    
    var body: some View {
        VStack(spacing: 0) {
            TopAppBarViewWithLogo()
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("privacy_title".localized)
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("privacy_content".localized)
                        
                        Button("accept_privacy_button".localized) {
                            prefs.savePrivacyAccepted(true)
                            coordinator.navigate(to: .login)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
            }
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
    }
}

struct PrivacyDialogView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("privacy_title".localized)
                .font(.headline)
                .padding(.top)
            
            ScrollView {
                Text("privacy_content".localized)
                    .font(.body)
                    .padding()
            }
            
            Button("close_button".localized) {
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
