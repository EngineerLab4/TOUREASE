import Foundation
import SwiftData

enum UserRole: String, Codable {
    case tourist
    case admin
}

/// App user. Role-based — admin vs tourist share the exact same login flow;
/// the destination screen after login is decided purely by `role`.
struct AppUser: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var email: String
    var role: UserRole
    var profileImageURL: String?
    var provider: AuthProvider
}

enum AuthProvider: String, Codable {
    case email, google, apple
}

/// Persisted locally (SwiftData) so "Remember Me" survives app relaunch offline.
@Model
final class SessionRecord {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var roleRaw: String
    var provider: String
    var rememberMe: Bool
    var lastLoginDate: Date

    init(id: String, name: String, email: String, role: UserRole, provider: AuthProvider, rememberMe: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.roleRaw = role.rawValue
        self.provider = provider.rawValue
        self.rememberMe = rememberMe
        self.lastLoginDate = .now
    }

    var role: UserRole { UserRole(rawValue: roleRaw) ?? .tourist }
}
