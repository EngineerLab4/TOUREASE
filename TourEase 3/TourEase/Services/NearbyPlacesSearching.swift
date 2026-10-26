import Foundation
import MapKit
import CoreLocation

enum NearbyPlacesError: LocalizedError {
    case noResults

    var errorDescription: String? {
        "No places found nearby for this category."
    }
}

protocol NearbyPlacesSearching {
    func search(category: NearbyCategory, center: CLLocationCoordinate2D) async throws -> [NearbyPlace]
}

final class NearbyPlacesSearchService: NearbyPlacesSearching {
    func search(category: NearbyCategory, center: CLLocationCoordinate2D) async throws -> [NearbyPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.searchQuery
        request.region = MKCoordinateRegion(center: center, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        request.resultTypes = [.pointOfInterest]
        if let filter = category.poiFilter {
            request.pointOfInterestFilter = filter
        }

        let response = try await MKLocalSearch(request: request).start()
        guard !response.mapItems.isEmpty else {
            throw NearbyPlacesError.noResults
        }

        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        return response.mapItems.map { item in
            let name = item.name ?? category.displayName
            let address = item.compatFormattedAddress
            let coordinate = item.compatCoordinate
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: centerLocation)
            return NearbyPlace(
                id: "\(name)|\(address)|\(category.rawValue)",
                name: name,
                address: address,
                coordinate: coordinate,
                distanceMeters: distance,
                category: category
            )
        }
        .sorted { $0.distanceMeters < $1.distanceMeters }
    }
}
