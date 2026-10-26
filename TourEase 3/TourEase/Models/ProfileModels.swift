import Foundation
import SwiftData

/// Local customization layer on top of `AppUser` (which comes fresh from
/// auth each session and isn't itself persisted). Keyed by the signed-in
/// user's id so a custom display name, photo, and notification preference
/// survive logout/login on the same device.
@Model
final class UserProfileRecord {
    @Attribute(.unique) var id: String
    var customDisplayName: String
    var profileImageData: Data?
    var notificationsEnabled: Bool
    var updatedDate: Date

    init(userID: String, displayName: String) {
        self.id = userID
        self.customDisplayName = displayName
        self.profileImageData = nil
        self.notificationsEnabled = true
        self.updatedDate = .now
    }
}
