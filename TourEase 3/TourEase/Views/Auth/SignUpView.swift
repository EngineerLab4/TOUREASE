import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            AnimatedBackground(imageNames: [])

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.white.opacity(0.08), in: Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    VStack(spacing: 6) {
                        Text("Create your account")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Plan smarter trips from day one")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                    }

                    GlassCard {
                        VStack(spacing: 16) {
                            FloatingTextField(title: "Full name", systemImage: "person.fill", text: $vm.name)
                            FloatingTextField(title: "Email", systemImage: "envelope.fill",
                                               text: $vm.email, keyboardType: .emailAddress)

                            FloatingTextField(title: "Password", systemImage: "lock.fill",
                                               text: $vm.password, isSecure: true,
                                               isPasswordVisible: vm.isPasswordVisible)

                            if !vm.password.isEmpty {
                                Text("Strength: \(Validators.passwordStrengthLabel(vm.password))")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(Color.touroTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(spacing: 10) {
                                FloatingTextField(title: "Confirm password", systemImage: "lock.rotation",
                                                   text: $vm.confirmPassword, isSecure: true,
                                                   isPasswordVisible: vm.isPasswordVisible)
                                Button {
                                    vm.isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: vm.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(Color.touroTextMuted)
                                }
                                .accessibilityLabel(vm.isPasswordVisible ? "Hide password" : "Show password")
                            }

                            if let error = vm.errorMessage {
                                Text(error)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color.touroSunset)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryButton(title: "Sign Up", isLoading: vm.isLoading) {
                                Task {
                                    await vm.signUp()
                                    if vm.errorMessage == nil { dismiss() }
                                }
                            }
                            .shake(vm.shakeTrigger)
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("By signing up you agree to TourEase's Terms & Privacy Policy.")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SignUpView()
        .environment(AuthViewModel(authService: MockAuthService(), sessionManager: SessionManager()))
}
