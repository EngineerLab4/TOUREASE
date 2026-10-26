import Foundation
import SwiftData
import Observation

/// Single source of truth for "who's logged in right now" + remember-me persistence.
/// Injected into the environment at the App root; drives which root screen shows.
@Observable
final class SessionManager {
    var currentUser: AppUser?
    var isRestoringSession = true

    private var modelContext: ModelContext?

    func attach(context: ModelContext) {
        self.modelContext = context
        restoreSessionIfNeeded()
    }

    func restoreSessionIfNeeded() {
        defer { isRestoringSession = false }
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SessionRecord>(predicate: #Predicate { $0.rememberMe == true })
        if let record = try? modelContext.fetch(descriptor).first {
            currentUser = AppUser(id: record.id, name: record.name, email: record.email,
                                   role: record.role, profileImageURL: nil,
                                   provider: AuthProvider(rawValue: record.provider) ?? .email)
        }
    }

    func startSession(for user: AppUser, rememberMe: Bool) {
        currentUser = user
        guard let modelContext else { return }
        // Clear any prior remembered session, then persist if requested.
        let descriptor = FetchDescriptor<SessionRecord>()
        if let existing = try? modelContext.fetch(descriptor) {
            existing.forEach { modelContext.delete($0) }
        }
        if rememberMe {
            let record = SessionRecord(id: user.id, name: user.name, email: user.email,
                                        role: user.role, provider: user.provider, rememberMe: true)
            modelContext.insert(record)
        }
        try? modelContext.save()
    }

    func signOut() {
        currentUser = nil
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SessionRecord>()
        if let existing = try? modelContext.fetch(descriptor) {
            existing.forEach { modelContext.delete($0) }
        }
        try? modelContext.save()
    }
}
