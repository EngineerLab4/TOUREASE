import SwiftUI

struct ForgotPasswordView: View {
    @Environment(AuthViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            AnimatedBackground(imageNames: [])

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                if vm.didSendResetEmail {
                    VStack(spacing: 14) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.touroTealLight)
                        Text("Check your inbox")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("We've sent a password reset link to \(vm.email).")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                            .multilineTextAlignment(.center)
                        PrimaryButton(title: "Done") { dismiss() }
                            .padding(.top, 8)
                    }
                    .padding(24)
                } else {
                    VStack(spacing: 6) {
                        Text("Reset your password")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Enter the email linked to your account.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                    }
                    .padding(.top, 8)

                    GlassCard {
                        VStack(spacing: 16) {
                            FloatingTextField(title: "Email", systemImage: "envelope.fill",
                                               text: $vm.email, keyboardType: .emailAddress)

                            if let error = vm.errorMessage {
                                Text(error)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color.touroSunset)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryButton(title: "Send Reset Link", isLoading: vm.isLoading) {
                                Task { await vm.sendPasswordReset() }
                            }
                            .shake(vm.shakeTrigger)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ForgotPasswordView()
        .environment(AuthViewModel(authService: MockAuthService(), sessionManager: SessionManager()))
}
