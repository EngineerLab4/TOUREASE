import Foundation
import MapKit
import CoreLocation

enum FoodServiceError: LocalizedError {
    case placeNotFound(String)
    case noResults

    var errorDescription: String? {
        switch self {
        case .placeNotFound(let query): return "Couldn't find a location matching \"\(query)\"."
        case .noResults: return "No restaurants or cafes found near that location."
        }
    }
}

/// Real MapKit POI search for `.restaurant` and `.cafe` near a resolved
/// destination — same hybrid pattern as `HotelSearchService`: genuine
/// places, estimated cost.
protocol FoodPlaceSearching {
    func searchPlaces(near destinationQuery: String) async throws -> [FoodPlace]
}

final class FoodPlaceSearchService: FoodPlaceSearching {
    private let pricing: FoodPricingProviding

    init(pricing: FoodPricingProviding = DefaultFoodPricingProvider()) {
        self.pricing = pricing
    }

    func searchPlaces(near destinationQuery: String) async throws -> [FoodPlace] {
        let placeRequest = MKLocalSearch.Request()
        placeRequest.naturalLanguageQuery = destinationQuery
        placeRequest.resultTypes = [.address, .pointOfInterest]
        let placeResponse = try? await MKLocalSearch(request: placeRequest).start()
        guard let destinationItem = placeResponse?.mapItems.first else {
            throw FoodServiceError.placeNotFound(destinationQuery)
        }
        let center = destinationItem.compatCoordinate
        let destinationLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        async let restaurantsTask = search(center: center, category: .restaurant)
        async let cafesTask = search(center: center, category: .cafe)
        let restaurants = try await restaurantsTask
        let cafes = try await cafesTask
        let combined = restaurants + cafes

        guard !combined.isEmpty else { throw FoodServiceError.noResults }

        return combined.map { (item, venueType) in
            let name = item.name ?? venueType.displayName
            let address = item.compatFormattedAddress
            let coordinate = item.compatCoordinate
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: destinationLocation)
            return FoodPlace(
                id: "\(name)|\(address)",
                name: name,
                address: address,
                coordinate: coordinate,
                distanceMeters: distance,
                venueType: venueType,
                averageCostPerVisit: pricing.averageCost(venueType == .restaurant ? .restaurant : .cafe)
            )
        }
        .sorted { $0.distanceMeters < $1.distanceMeters }
    }

    private func search(center: CLLocationCoordinate2D, category: MKPointOfInterestCategory) async throws -> [(MKMapItem, FoodVenueType)] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category == .restaurant ? "restaurants" : "cafes"
        request.region = MKCoordinateRegion(center: center, latitudinalMeters: 8_000, longitudinalMeters: 8_000)
        request.resultTypes = [.pointOfInterest]
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])

        let response = try? await MKLocalSearch(request: request).start()
        let venueType: FoodVenueType = category == .restaurant ? .restaurant : .cafe
        return (response?.mapItems ?? []).map { ($0, venueType) }
    }
}
