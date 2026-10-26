import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case wrongCredentials
    case emailAlreadyInUse
    case userNotFound
    case network
    case cancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .weakPassword: return "Password must be at least 8 characters with a letter and a number."
        case .wrongCredentials: return "Incorrect email or password."
        case .emailAlreadyInUse: return "An account with this email already exists."
        case .userNotFound: return "No account found for that email."
        case .network: return "Network error. Check your connection and try again."
        case .cancelled: return "Sign-in was cancelled."
        case .unknown(let msg): return msg
        }
    }
}

/// Abstraction over the auth backend so the app can run fully on `MockAuthService`
/// today and swap in `FirebaseAuthService` later with zero changes to ViewModels/Views.
protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(name: String, email: String, password: String) async throws -> AppUser
    func signInWithGoogle() async throws -> AppUser
    func signInWithApple() async throws -> AppUser
    func sendPasswordReset(email: String) async throws
    func signOut() throws
}
