import SwiftUI

/// Every destination reachable from the Home Dashboard. Used both to render
/// the grid of cards and to drive `NavigationStack`'s type-safe routing
/// (`.navigationDestination(for: DashboardDestination.self)`).
///
/// As each later module lands (Route Planner, Budget Planner, Hotels, ...),
/// its case gets a real screen in `DashboardView`'s navigationDestination
/// switch — nothing here needs to change.
enum DashboardDestination: String, CaseIterable, Identifiable, Hashable {
    case planTrip
    case routePlanner
    case compareTransport
    case budgetPlanner
    case hotels
    case food
    case weather
    case nearbyPlaces
    case emergency
    case savedTrips
    case history
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .planTrip: return "Plan Trip"
        case .routePlanner: return "Route Planner"
        case .compareTransport: return "Compare Transport"
        case .budgetPlanner: return "Budget Planner"
        case .hotels: return "Hotels"
        case .food: return "Food"
        case .weather: return "Weather"
        case .nearbyPlaces: return "Nearby Places"
        case .emergency: return "Emergency"
        case .savedTrips: return "Saved Trips"
        case .history: return "History"
        case .profile: return "Profile"
        }
    }

    var subtitle: String {
        switch self {
        case .planTrip: return "Start a new journey"
        case .routePlanner: return "Map your route"
        case .compareTransport: return "Car, bus, train & more"
        case .budgetPlanner: return "Estimate your spend"
        case .hotels: return "Find a place to stay"
        case .food: return "Meal cost estimates"
        case .weather: return "Live conditions"
        case .nearbyPlaces: return "Attractions & essentials"
        case .emergency: return "Quick help contacts"
        case .savedTrips: return "Your planned trips"
        case .history: return "Past searches"
        case .profile: return "Account & settings"
        }
    }

    var systemImage: String {
        switch self {
        case .planTrip: return "map.fill"
        case .routePlanner: return "point.topleft.down.curvedto.point.bottomright.up.fill"
        case .compareTransport: return "arrow.left.arrow.right.circle.fill"
        case .budgetPlanner: return "indianrupeesign.circle.fill"
        case .hotels: return "bed.double.fill"
        case .food: return "fork.knife.circle.fill"
        case .weather: return "cloud.sun.fill"
        case .nearbyPlaces: return "mappin.and.ellipse"
        case .emergency: return "cross.case.fill"
        case .savedTrips: return "bookmark.fill"
        case .history: return "clock.arrow.circlepath"
        case .profile: return "person.crop.circle.fill"
        }
    }

    /// Two-tone gradient used for each card's icon bubble — cycles through
    /// the app's teal/sunset accent family so the grid reads as premium,
    /// not flat/uniform.
    var accentGradient: LinearGradient {
        let pairs: [[Color]] = [
            [.touroTeal, .touroTealLight],
            [.touroSunset, Color(red: 0.98, green: 0.72, blue: 0.35)],
            [Color(red: 0.35, green: 0.45, blue: 0.95), Color(red: 0.55, green: 0.65, blue: 1.0)],
            [Color(red: 0.85, green: 0.35, blue: 0.55), Color(red: 0.98, green: 0.55, blue: 0.65)],
        ]
        let index = (Self.allCases.firstIndex(of: self) ?? 0) % pairs.count
        return LinearGradient(colors: pairs[index], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Whether this destination has a real built screen yet. Everything not
    /// listed here routes to `ComingSoonView` until its module lands.
    var isImplemented: Bool {
        self == .emergency || self == .routePlanner || self == .compareTransport || self == .budgetPlanner || self == .hotels || self == .food || self == .nearbyPlaces || self == .weather || self == .history || self == .savedTrips
    }
}
