import SwiftUI

struct TermsView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @ObservedObject var prefs: PreferencesManager

    var body: some View {
        VStack(spacing: 0) {
            TopAppBarComponentWithLogo()

            Spacer()

            VStack(spacing: 16) {

                Text("terms_title".localized)
                    .font(.title)
                    .bold()
                    .padding(.top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("terms_content".localized)

                        Button("accept_terms_button".localized) {
                            prefs.saveTermsAccepted(true)
                            coordinator.navigate(to: .privacyPolicy)
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

struct TermsDialogView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("terms_title".localized)
                .font(.headline)
                .padding(.top)

            ScrollView {
                Text("terms_content".localized)
                    .font(.body)
                    .padding()
            }

            Button("close_button".localized){
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
