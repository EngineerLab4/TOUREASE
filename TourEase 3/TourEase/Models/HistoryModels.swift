import Foundation
import SwiftData

/// Which screen a logged search came from — drives the icon shown in the
/// Search History list. `Budgets` and `Favourite Hotels` don't need an
/// entry here since they already have their own dedicated SwiftData models
/// (`BudgetRecord` from Module 4, `FavoriteHotel` from Module 5) that
/// History reads directly rather than duplicating.
enum SearchHistoryCategory: String {
    case hotel, food, nearbyPlace, weather

    var displayName: String {
        switch self {
        case .hotel: return "Hotels"
        case .food: return "Food"
        case .nearbyPlace: return "Nearby Places"
        case .weather: return "Weather"
        }
    }

    var systemImage: String {
        switch self {
        case .hotel: return "bed.double.fill"
        case .food: return "fork.knife"
        case .nearbyPlace: return "mappin.and.ellipse"
        case .weather: return "cloud.sun.fill"
        }
    }
}

@Model
final class SearchHistoryRecord {
    @Attribute(.unique) var id: String
    var queryText: String
    var categoryRaw: String
    var timestamp: Date

    init(queryText: String, category: SearchHistoryCategory) {
        self.id = UUID().uuidString
        self.queryText = queryText
        self.categoryRaw = category.rawValue
        self.timestamp = .now
    }

    var category: SearchHistoryCategory { SearchHistoryCategory(rawValue: categoryRaw) ?? .nearbyPlace }
}

/// Doubles as both "Recent Routes" and "Trips" per the spec — a calculated
/// route already captures source, destination, distance, and time; a
/// separate "Trip" record would just duplicate it until the standalone
/// "Plan Trip" flow exists.
@Model
final class RecentRouteRecord {
    @Attribute(.unique) var id: String
    var sourceName: String
    var destinationName: String
    var distanceMeters: Double
    var travelTimeSeconds: Double
    var timestamp: Date

    init(result: RouteResult) {
        self.id = UUID().uuidString
        self.sourceName = result.sourceName
        self.destinationName = result.destinationName
        self.distanceMeters = result.distanceMeters
        self.travelTimeSeconds = result.expectedTravelTime
        self.timestamp = .now
    }

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m" : String(format: "%.1f km", km)
    }

    var timeText: String {
        let minutes = Int(travelTimeSeconds / 60)
        return minutes < 60 ? "\(minutes) min" : "\(minutes / 60) hr \(minutes % 60) min"
    }
}

/// Single-row settings record — one instance with a fixed id, created on
/// first save. Edited directly from the History screen's Preferences tab.
@Model
final class UserPreferencesRecord {
    @Attribute(.unique) var id: String
    var preferredHotelCategoryRaw: String
    var preferredFoodPreferenceRaw: String
    var defaultTripDays: Int
    var updatedDate: Date

    static let fixedID = "user_preferences"

    init(hotelCategory: HotelCategory = .standard, foodPreference: FoodPreference = .standardDining, defaultTripDays: Int = 3) {
        self.id = Self.fixedID
        self.preferredHotelCategoryRaw = hotelCategory.rawValue
        self.preferredFoodPreferenceRaw = foodPreference.rawValue
        self.defaultTripDays = defaultTripDays
        self.updatedDate = .now
    }

    var preferredHotelCategory: HotelCategory { HotelCategory(rawValue: preferredHotelCategoryRaw) ?? .standard }
    var preferredFoodPreference: FoodPreference { FoodPreference(rawValue: preferredFoodPreferenceRaw) ?? .standardDining }
}
