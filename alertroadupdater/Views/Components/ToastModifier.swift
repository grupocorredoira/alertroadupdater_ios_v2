import SwiftUI

struct ToastModifier: ViewModifier {
    let message: String
    let icon: String?
    @Binding var isShowing: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message, icon: icon)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: isShowing)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(message: String, icon: String? = nil, isShowing: Binding<Bool>, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(message: message, icon: icon, isShowing: isShowing, duration: duration))
    }
}
