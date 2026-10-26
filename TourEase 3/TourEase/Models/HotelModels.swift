import Foundation
import CoreLocation
import SwiftData

/// A hotel returned from a real MapKit POI search near the destination.
/// `name`, `address`, `coordinate`, and `distanceMeters` are genuine data;
/// `category`, `averagePricePerNight`, and `averageRating` are estimated —
/// Apple's free MapKit search doesn't expose pricing tier or star rating,
/// so those are assigned by `HotelEstimating` and clearly labeled
/// "Estimated" in the UI, same honesty rule as the Transport module.
struct Hotel: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let category: HotelCategory
    let averagePricePerNight: Double
    let averageRating: Double

    static func == (lhs: Hotel, rhs: Hotel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m away" : String(format: "%.1f km away", km)
    }

    var priceText: String { "₹\(Int(averagePricePerNight.rounded()))/night" }
    var ratingText: String { String(format: "%.1f", averageRating) }
}

enum HotelSortOption: String, LabeledOption {
    case priceLowToHigh, ratingHighToLow, nearest
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .priceLowToHigh: return "Price"
        case .ratingHighToLow: return "Rating"
        case .nearest: return "Nearest"
        }
    }
}

/// Adds an "All" option on top of `HotelCategory` for the filter row —
/// reuses `PillSegmentedControl` rather than a bespoke filter component.
enum HotelCategoryFilter: String, LabeledOption {
    case all, budget, standard, premium, luxury
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .all: return "All"
        case .budget: return "Budget"
        case .standard: return "Standard"
        case .premium: return "Premium"
        case .luxury: return "Luxury"
        }
    }
    var hotelCategory: HotelCategory? {
        switch self {
        case .all: return nil
        case .budget: return .budget
        case .standard: return .standard
        case .premium: return .premium
        case .luxury: return .luxury
        }
    }
}

/// Persisted when the user taps the favorite heart. Stores a snapshot of
/// the hotel (not a live MapKit reference, which can't be persisted) so
/// favorites still render correctly offline.
@Model
final class FavoriteHotel {
    @Attribute(.unique) var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var categoryRaw: String
    var averagePricePerNight: Double
    var averageRating: Double
    var savedDate: Date

    init(hotel: Hotel) {
        self.id = hotel.id
        self.name = hotel.name
        self.address = hotel.address
        self.latitude = hotel.coordinate.latitude
        self.longitude = hotel.coordinate.longitude
        self.categoryRaw = hotel.category.rawValue
        self.averagePricePerNight = hotel.averagePricePerNight
        self.averageRating = hotel.averageRating
        self.savedDate = .now
    }
}
