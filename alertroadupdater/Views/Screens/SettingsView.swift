import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @State private var showDialogSafeDisconnect = false
    @State private var showPrivacyPolicyDialog = false
    @State private var showTermsDialog = false
    @State private var showToastDeleteLocalFiles = false
    @State private var toastMessageDeleteLocalFiles = ""
    @EnvironmentObject var coordinator: NavigationCoordinator

    let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"

    var body: some View {

        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                CustomNavigationBar(
                    title: "settings_label".localized,
                    showBackButton: true
                ) {
                    coordinator.pop()
                }

                Section(header: Text("user_preferences".localized).font(.headline)) {
                    SettingsOption(title: "privacy_policy_option".localized) {
                        showPrivacyPolicyDialog = true
                    }
                    SettingsOption(title: "terms_conditions_option".localized) {
                        showTermsDialog = true
                    }
                    SettingsOption(title: "delete_files_option".localized) {
                        deleteLocalFiles()
                    }
                    SettingsOption(title: "disconnect_option".localized) {
                        showDialogSafeDisconnect = true
                    }
                }

                Spacer()

                Text(String(format: "version_code_text".localized, versionName, versionCode))
                    .font(.footnote)
                    .padding()
            }
            .overlay {
                if showDialogSafeDisconnect {
                    disconnectDialog()
                } else if showPrivacyPolicyDialog {
                    PrivacyDialogView {
                        showPrivacyPolicyDialog = false
                    }
                } else if showTermsDialog {
                    TermsDialogView {
                        showTermsDialog = false
                    }
                }
            }
            .padding(.top, 8)
            .navigationBarHidden(true)
            .onAppear {
                coordinator.pushIfNeeded(.settings)
            }
            .onDisappear {
                print("👋 SettingsView desapareció")
            }
            .toast(message: toastMessageDeleteLocalFiles, icon: "trash", isShowing: $showToastDeleteLocalFiles)
        }
    }

    private func deleteLocalFiles() {
        let message = documentsViewModel.deleteAllLocalFiles()
        toastMessageDeleteLocalFiles = message
        showToastDeleteLocalFiles = true
    }

    @ViewBuilder
    private func disconnectDialog() -> some View {
        VStack() {
            Text("disconnect_title".localized)
                .font(.headline)
                .padding()

            Text("disconnect_message".localized)
                .font(.subheadline)
                .padding()

            HStack(spacing: 12) {
                Button(action: {
                    signOut()
                    showDialogSafeDisconnect = false
                    coordinator.popTo(.login)
                }) {
                    Text("logout_button".localized)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                Button(action: {
                    showDialogSafeDisconnect = false
                }) {
                    Text("cancel_button".localized)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()

        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Sesión cerrada correctamente")
            coordinator.navigate(to: .login)
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
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
