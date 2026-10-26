import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class ProfileViewModel {
    var displayName: String = ""
    var profileImageData: Data?
    var notificationsEnabled: Bool = true
    var didSave = false

    func load(from record: UserProfileRecord?, fallbackName: String) {
        if let record {
            displayName = record.customDisplayName
            profileImageData = record.profileImageData
            notificationsEnabled = record.notificationsEnabled
        } else {
            displayName = fallbackName
        }
    }

    @MainActor
    func save(userID: String, existing: UserProfileRecord?, context: ModelContext) {
        if let existing {
            existing.customDisplayName = displayName
            existing.profileImageData = profileImageData
            existing.notificationsEnabled = notificationsEnabled
            existing.updatedDate = .now
        } else {
            let record = UserProfileRecord(userID: userID, displayName: displayName)
            record.profileImageData = profileImageData
            record.notificationsEnabled = notificationsEnabled
            context.insert(record)
        }
        try? context.save()
        withAnimation(.easeInOut) { didSave = true }
    }
}
