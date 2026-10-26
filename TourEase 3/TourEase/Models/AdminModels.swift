import Foundation
import SwiftData

/// Local stand-in for what would be a live Firestore `users` collection
/// query once Firebase is wired (see `FirebaseAuthService.fetchOrCreateUserDoc`,
/// already commented in as the real path). `MockAuthService` never creates a
/// durable multi-user directory — each login just returns a fresh `AppUser`
/// — so without a backend there is no real "all users of the app" list to
/// show. This seeds a small labeled demo directory on first visit so
/// Manage Users is fully functional to demo (suspend/delete really work,
/// persisted via SwiftData), while being honest that it isn't live
/// production user data.
@Model
final class AppUserRecord {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var roleRaw: String
    var isSuspended: Bool
    var joinedDate: Date

    init(id: String = UUID().uuidString, name: String, email: String, role: UserRole, joinedDate: Date = .now) {
        self.id = id
        self.name = name
        self.email = email
        self.roleRaw = role.rawValue
        self.isSuspended = false
        self.joinedDate = joinedDate
    }

    var role: UserRole { UserRole(rawValue: roleRaw) ?? .tourist }
}

enum SampleUserSeed {
    /// Called once from the Admin Portal if `AppUserRecord` is empty.
    static func seed(into context: ModelContext) {
        let samples: [(String, String, UserRole)] = [
            ("Aarav Sharma", "aarav@tourease.com", .tourist),
            ("Priya Menon", "priya@tourease.com", .tourist),
            ("Rohan Gupta", "rohan@tourease.com", .tourist),
            ("Ishaan Verma", "ishaan.admin@tourease.com", .admin),
            ("Ananya Iyer", "ananya@tourease.com", .tourist),
        ]
        for (name, email, role) in samples {
            context.insert(AppUserRecord(name: name, email: email, role: role, joinedDate: .now.addingTimeInterval(-Double.random(in: 86_400...2_592_000))))
        }
        try? context.save()
    }
}
