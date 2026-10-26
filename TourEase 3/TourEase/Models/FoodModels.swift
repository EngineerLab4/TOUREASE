import Foundation
import CoreLocation

/// The six cost categories from the spec. Breakfast/Lunch/Dinner are
/// meal-time averages (used to build Daily/Weekly Average); Street Food/
/// Restaurant/Cafe are venue-type averages (shown as reference cost bands,
/// not summed into the daily total — a sit-down Restaurant dinner would
/// otherwise double-count against the "Dinner" line).
enum FoodCategory: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, streetFood, restaurant, cafe
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .streetFood: return "Street Food"
        case .restaurant: return "Restaurant"
        case .cafe: return "Cafe"
        }
    }

    var systemImage: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars.fill"
        case .streetFood: return "takeoutbag.and.cup.and.straw.fill"
        case .restaurant: return "fork.knife.circle.fill"
        case .cafe: return "cup.and.saucer.fill"
        }
    }

    /// Whether this category sums into Daily/Weekly Average.
    var countsTowardDailyAverage: Bool {
        self == .breakfast || self == .lunch || self == .dinner
    }
}

enum FoodVenueType: String {
    case restaurant, cafe
    var displayName: String { self == .restaurant ? "Restaurant" : "Cafe" }
}

/// A real restaurant/cafe from MapKit POI search near a destination.
/// `name`/`address`/`coordinate`/`distanceMeters` are genuine; the cost
/// estimate comes from `FoodPricingProviding` (Apple's free search doesn't
/// expose menu prices), same honesty split as the Hotels module.
struct FoodPlace: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let venueType: FoodVenueType
    let averageCostPerVisit: Double

    static func == (lhs: FoodPlace, rhs: FoodPlace) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m away" : String(format: "%.1f km away", km)
    }

    var costText: String { "₹\(Int(averageCostPerVisit.rounded())) avg" }
}
