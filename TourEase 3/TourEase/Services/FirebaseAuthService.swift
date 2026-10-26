import Foundation
import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn

/// Real backend implementation — email/password, Google, and Apple sign-in
/// via Firebase Auth, with role stored in Firestore.
final class FirebaseAuthService: NSObject, AuthServicing {

    // MARK: - Email / Password

    func signIn(email: String, password: String) async throws -> AppUser {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return try await fetchOrCreateUserDoc(uid: result.user.uid, email: email,
                                                   name: result.user.displayName, provider: .email)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    func signUp(name: String, email: String, password: String) async throws -> AppUser {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            return try await fetchOrCreateUserDoc(uid: result.user.uid, email: email, name: name, provider: .email)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Google

    func signInWithGoogle() async throws -> AppUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown("Firebase isn't configured — check GoogleService-Info.plist is added to the target.")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let rootViewController = Self.topViewController() else {
            throw AuthError.unknown("Couldn't find a screen to present Google Sign-In from.")
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown("Google didn't return an ID token.")
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            return try await fetchOrCreateUserDoc(uid: authResult.user.uid, email: authResult.user.email ?? "",
                                                   name: authResult.user.displayName, provider: .google)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Apple (disabled — needs paid Apple Developer account, skipped for now)

    func signInWithApple() async throws -> AppUser {
        throw AuthError.unknown("Apple Sign-In isn't set up yet — use Email or Google for now.")
    }

    // MARK: - Sign out

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Firestore role lookup

    private func fetchOrCreateUserDoc(uid: String, email: String, name: String?, provider: AuthProvider) async throws -> AppUser {
        let ref = Firestore.firestore().collection("users").document(uid)
        do {
            let snapshot = try await ref.getDocument()
            if let data = snapshot.data(), let roleRaw = data["role"] as? String {
                return AppUser(id: uid, name: data["name"] as? String ?? name ?? "Traveler", email: email,
                                role: UserRole(rawValue: roleRaw) ?? .tourist,
                                profileImageURL: data["profileImageURL"] as? String, provider: provider)
            } else {
                let role: UserRole = email.lowercased().contains("admin") ? .admin : .tourist
                try await ref.setData(["name": name ?? "Traveler", "email": email, "role": role.rawValue])
                return AppUser(id: uid, name: name ?? "Traveler", email: email, role: role,
                                profileImageURL: nil, provider: provider)
            }
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Error mapping

    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.localizedDescription)
        }
        switch code {
        case .invalidEmail: return .invalidEmail
        case .weakPassword: return .weakPassword
        case .wrongPassword, .invalidCredential: return .wrongCredentials
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .userNotFound: return .userNotFound
        case .networkError: return .network
        default: return .unknown(nsError.localizedDescription)
        }
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }
}
