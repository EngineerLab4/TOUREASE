import Foundation

/// Fully working simulated backend — lets the app be built, run, and demoed
/// today with zero external setup. Swap the service in TourEaseApp
/// once Firebase is wired to switch to `FirebaseAuthService` instead.
///
/// Registered accounts are persisted locally (UserDefaults) so only users
/// who actually signed up can log in — real authorization instead of
/// accepting any email/password pair. Still a mock backend (no server,
/// password stored locally in plain text) — real hashing/server validation
/// arrives with `FirebaseAuthService`.
final class MockAuthService: AuthServicing {

    private struct RegisteredUser: Codable {
        let id: String
        let name: String
        let email: String
        let password: String
    }

    private let storageKey = "tourease.mock.registeredUsers"

    private var registeredUsers: [RegisteredUser] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let users = try? JSONDecoder().decode([RegisteredUser].self, from: data) else { return [] }
            return users
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// Any email containing "admin" logs in with the admin role — lets you
    /// demo the same login screen routing to the Admin Portal (Phase 4)
    /// without a separate admin login button, per spec.
    private func roleFor(email: String) -> UserRole {
        email.lowercased().contains("admin") ? .admin : .tourist
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 900_000_000)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }

        let normalizedEmail = email.lowercased()
        guard let match = registeredUsers.first(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AuthError.userNotFound
        }
        guard match.password == password else {
            throw AuthError.wrongCredentials
        }

        return AppUser(
            id: match.id,
            name: match.name,
            email: match.email,
            role: roleFor(email: match.email),
            profileImageURL: nil,
            provider: .email
        )
    }

    func signUp(name: String, email: String, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 1_100_000_000)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }

        let normalizedEmail = email.lowercased()
        guard !registeredUsers.contains(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AuthError.emailAlreadyInUse
        }

        let newUser = RegisteredUser(
            id: UUID().uuidString,
            name: name.isEmpty ? "Traveler" : name,
            email: email,
            password: password
        )
        registeredUsers.append(newUser)

        return AppUser(
            id: newUser.id,
            name: newUser.name,
            email: newUser.email,
            role: roleFor(email: newUser.email),
            profileImageURL: nil,
            provider: .email
        )
    }

    func signInWithGoogle() async throws -> AppUser {
        try await Task.sleep(nanoseconds: 900_000_000)
        return AppUser(id: UUID().uuidString, name: "Google Traveler", email: "traveler@gmail.com",
                        role: .tourist, profileImageURL: nil, provider: .google)
    }

    func signInWithApple() async throws -> AppUser {
        try await Task.sleep(nanoseconds: 900_000_000)
        return AppUser(id: UUID().uuidString, name: "Apple Traveler", email: "traveler@icloud.com",
                        role: .tourist, profileImageURL: nil, provider: .apple)
    }

    func sendPasswordReset(email: String) async throws {
        try await Task.sleep(nanoseconds: 700_000_000)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        let normalizedEmail = email.lowercased()
        guard registeredUsers.contains(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AuthError.userNotFound
        }
    }

    func signOut() throws {}
}
