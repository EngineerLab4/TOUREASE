import Foundation
import SwiftData

/// One-line call from any search-driven screen's `.onChange` — keeps the
/// actual logging logic in one place instead of duplicating insert/save
/// boilerplate across five views.
enum SearchHistoryLogger {
    static func log(query: String, category: SearchHistoryCategory, context: ModelContext) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        context.insert(SearchHistoryRecord(queryText: trimmed, category: category))
        try? context.save()
    }
}
