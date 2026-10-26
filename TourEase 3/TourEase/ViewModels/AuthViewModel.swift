import Foundation
import Observation
import SwiftUI

enum AuthField {
    case email, password, confirmPassword, name
}

@Observable
final class AuthViewModel {
    // Shared login/signup fields
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var rememberMe: Bool = true
    var isPasswordVisible: Bool = false

    // UI state
    var isLoading: Bool = false
    var errorMessage: String?
    var shakeTrigger: CGFloat = 0
    var didSendResetEmail: Bool = false

    private let authService: AuthServicing
    private let sessionManager: SessionManager

    init(authService: AuthServicing, sessionManager: SessionManager) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    var isLoginFormValid: Bool {
        Validators.isValidEmail(email) && password.count >= 6
    }

    var isSignUpFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Validators.isValidEmail(email) &&
        Validators.isValidPassword(password) &&
        password == confirmPassword
    }

    @MainActor
    func signIn() async {
        guard isLoginFormValid else { return triggerError("Enter a valid email and password (6+ characters).") }
        isLoading = true; errorMessage = nil
        do {
            let user = try await authService.signIn(email: email, password: password)
            sessionManager.startSession(for: user, rememberMe: rememberMe)
        } catch {
            triggerError(error.localizedDescription)
        }
        isLoading = false
    }

    @MainActor
    func signUp() async {
        guard isSignUpFormValid else {
            if password != confirmPassword {
                return triggerError("Passwords don't match.")
            }
            return triggerError("Please fill every field correctly. Password needs 8+ chars, a letter and a number.")
        }
        isLoading = true; errorMessage = nil
        do {
            let user = try await authService.signUp(name: name, email: email, password: password)
            sessionManager.startSession(for: user, rememberMe: rememberMe)
        } catch {
            triggerError(error.localizedDescription)
        }
        isLoading = false
    }

    @MainActor
    func signInWithGoogle() async {
        isLoading = true; errorMessage = nil
        do {
            let user = try await authService.signInWithGoogle()
            sessionManager.startSession(for: user, rememberMe: rememberMe)
        } catch {
            triggerError(error.localizedDescription)
        }
        isLoading = false
    }

    @MainActor
    func signInWithApple() async {
        isLoading = true; errorMessage = nil
        do {
            let user = try await authService.signInWithApple()
            sessionManager.startSession(for: user, rememberMe: rememberMe)
        } catch {
            triggerError(error.localizedDescription)
        }
        isLoading = false
    }

    @MainActor
    func sendPasswordReset() async {
        guard Validators.isValidEmail(email) else { return triggerError("Enter a valid email first.") }
        isLoading = true; errorMessage = nil
        do {
            try await authService.sendPasswordReset(email: email)
            didSendResetEmail = true
        } catch {
            triggerError(error.localizedDescription)
        }
        isLoading = false
    }

    private func triggerError(_ message: String) {
        errorMessage = message
        withAnimation(.default.speed(2)) { shakeTrigger += 1 }
    }
}
