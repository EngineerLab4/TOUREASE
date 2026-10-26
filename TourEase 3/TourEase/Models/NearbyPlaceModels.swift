import Foundation
import MapKit

/// All 9 categories map to real `MKPointOfInterestCategory` filters (or, for
/// Tourist Attractions where no single Apple category fits, a plain
/// natural-language query) — unlike Hotels/Food/Transport, nothing in this
/// module needs a mock layer. Every result is genuine MapKit data.
enum NearbyCategory: String, CaseIterable, Identifiable {
    case touristAttractions, museums, parks, restaurants, hospitals, police, atms, petrolPumps, hotels
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .touristAttractions: return "Attractions"
        case .museums: return "Museums"
        case .parks: return "Parks"
        case .restaurants: return "Restaurants"
        case .hospitals: return "Hospitals"
        case .police: return "Police"
        case .atms: return "ATMs"
        case .petrolPumps: return "Petrol Pumps"
        case .hotels: return "Hotels"
        }
    }

    var systemImage: String {
        switch self {
        case .touristAttractions: return "camera.fill"
        case .museums: return "building.columns.fill"
        case .parks: return "tree.fill"
        case .restaurants: return "fork.knife"
        case .hospitals: return "cross.fill"
        case .police: return "shield.lefthalf.filled"
        case .atms: return "banknote.fill"
        case .petrolPumps: return "fuelpump.fill"
        case .hotels: return "bed.double.fill"
        }
    }

    /// Natural-language query MapKit uses alongside (or instead of) a strict
    /// category filter.
    var searchQuery: String {
        switch self {
        case .touristAttractions: return "tourist attractions"
        case .museums: return "museums"
        case .parks: return "parks"
        case .restaurants: return "restaurants"
        case .hospitals: return "hospitals"
        case .police: return "police stations"
        case .atms: return "atms"
        case .petrolPumps: return "petrol pumps gas stations"
        case .hotels: return "hotels"
        }
    }

    /// `nil` for Tourist Attractions — no single Apple POI category covers
    /// "attraction" well, so that one relies on the natural-language query
    /// alone rather than an overly narrow filter.
    var poiFilter: MKPointOfInterestFilter? {
        switch self {
        case .touristAttractions: return nil
        case .museums: return MKPointOfInterestFilter(including: [.museum])
        case .parks: return MKPointOfInterestFilter(including: [.park, .nationalPark])
        case .restaurants: return MKPointOfInterestFilter(including: [.restaurant])
        case .hospitals: return MKPointOfInterestFilter(including: [.hospital])
        case .police: return MKPointOfInterestFilter(including: [.police])
        case .atms: return MKPointOfInterestFilter(including: [.atm])
        case .petrolPumps: return MKPointOfInterestFilter(including: [.gasStation])
        case .hotels: return MKPointOfInterestFilter(including: [.hotel])
        }
    }
}

struct NearbyPlace: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let category: NearbyCategory

    static func == (lhs: NearbyPlace, rhs: NearbyPlace) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m away" : String(format: "%.1f km away", km)
    }
}
