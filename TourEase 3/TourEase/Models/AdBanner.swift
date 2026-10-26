import Foundation
import SwiftData

/// Ad shown in the reserved banner slot on the Login screen.
/// Managed later in Phase 4's Admin Portal (create/delete/schedule).
@Model
final class AdBanner {
    @Attribute(.unique) var id: String
    var title: String
    var imageURLString: String
    var targetURLString: String?
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var sortOrder: Int

    init(id: String = UUID().uuidString,
         title: String,
         imageURLString: String,
         targetURLString: String? = nil,
         startDate: Date = .now,
         endDate: Date = .now.addingTimeInterval(60 * 60 * 24 * 30),
         isActive: Bool = true,
         sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.imageURLString = imageURLString
        self.targetURLString = targetURLString
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.sortOrder = sortOrder
    }

    var isCurrentlyRunning: Bool {
        isActive && startDate <= .now && endDate >= .now
    }
}
