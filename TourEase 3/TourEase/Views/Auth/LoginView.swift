import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(AuthViewModel.self) private var vm
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    @Query(filter: #Predicate<AdBanner> { $0.isActive }, sort: \AdBanner.sortOrder)
    private var candidateBanners: [AdBanner]

    /// `isCurrentlyRunning` also checks start/end dates, which `#Predicate`
    /// can express, but keeping the date check here (not in the query)
    /// means the banner list only re-evaluates when banners actually
    /// change, not continuously against `.now`.
    private var activeBanners: [AdBanner] { candidateBanners.filter { $0.isCurrentlyRunning } }

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            AnimatedBackground(imageNames: []) // add asset names once you drop photos in Resources/Backgrounds

            ScrollView {
                VStack(spacing: 20) {
                    // Reserved ad banner space, per spec — now backed by real
                    // AdBanner records managed from the Admin Portal, with
                    // image loading + offline caching (Module 12).
                    AdBannerSlot(banners: activeBanners)
                        .padding(.top, 8)

                    VStack(spacing: 6) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 36))
                            .foregroundStyle(LinearGradient.touroCTA)
                            .padding(.bottom, 4)
                        Text("TourEase")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Your smart tourist guide")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                    }
                    .padding(.top, 12)

                    GlassCard {
                        VStack(spacing: 16) {
                            FloatingTextField(title: "Email", systemImage: "envelope.fill",
                                               text: $vm.email, keyboardType: .emailAddress)

                            HStack(spacing: 10) {
                                FloatingTextField(title: "Password", systemImage: "lock.fill",
                                                   text: $vm.password, isSecure: true,
                                                   isPasswordVisible: vm.isPasswordVisible)
                                Button {
                                    vm.isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: vm.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(Color.touroTextMuted)
                                }
                                .accessibilityLabel(vm.isPasswordVisible ? "Hide password" : "Show password")
                            }

                            HStack {
                                Toggle(isOn: $vm.rememberMe) {
                                    Text("Remember me")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundStyle(Color.touroTextMuted)
                                }
                                .toggleStyle(.switch)
                                .tint(.touroTeal)

                                Spacer()

                                Button("Forgot password?") { showForgotPassword = true }
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.touroTealLight)
                            }

                            if let error = vm.errorMessage {
                                Text(error)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color.touroSunset)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryButton(title: "Log In", isLoading: vm.isLoading) {
                                Task { await vm.signIn() }
                            }
                            .shake(vm.shakeTrigger)

                            HStack {
                                Rectangle().fill(Color.touroGlassStroke).frame(height: 1)
                                Text("or continue with")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(Color.touroTextMuted)
                                    .fixedSize()
                                Rectangle().fill(Color.touroGlassStroke).frame(height: 1)
                            }
                            .padding(.vertical, 4)

                            HStack(spacing: 12) {
                                SocialButton(title: "Google", systemImage: "g.circle.fill") {
                                    Task { await vm.signInWithGoogle() }
                                }
                                SocialButton(title: "Apple", systemImage: "apple.logo") {
                                    Task { await vm.signInWithApple() }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 4) {
                        Text("New to TourEase?")
                            .foregroundStyle(Color.touroTextMuted)
                        Button("Create an account") { showSignUp = true }
                            .foregroundStyle(Color.touroTealLight)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14, design: .rounded))
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showSignUp) { SignUpView() }
        .sheet(isPresented: $showForgotPassword) { ForgotPasswordView() }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel(authService: MockAuthService(), sessionManager: SessionManager()))
        .modelContainer(for: [AdBanner.self], inMemory: true)
}
