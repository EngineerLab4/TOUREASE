import SwiftUI

/// Decides what the user sees: splash while restoring a remembered session,
/// LoginView if signed out, or the Dashboard/Admin Portal based on `role` —
/// same login screen for everyone, routing is role-based, per spec.
struct RootView: View {
    @Environment(SessionManager.self) private var session
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        Group {
            if session.isRestoringSession {
                SplashView()
            } else if let user = session.currentUser {
                switch user.role {
                case .admin:
                    AdminPortalView(user: user)
                case .tourist:
                    DashboardView(user: user)
                }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: session.currentUser)
        .animation(.easeInOut, value: session.isRestoringSession)
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 12) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient.touroCTA)
                Text("TourEase")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                ProgressView().tint(.white).padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }
}
