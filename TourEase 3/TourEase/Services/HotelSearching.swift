import Foundation
import MapKit
import CoreLocation

enum HotelServiceError: LocalizedError {
    case placeNotFound(String)
    case noResults

    var errorDescription: String? {
        switch self {
        case .placeNotFound(let query): return "Couldn't find a location matching \"\(query)\"."
        case .noResults: return "No hotels found near that location."
        }
    }
}

/// Real MapKit POI search (`MKPointOfInterestFilter(including: [.hotel])`)
/// around a resolved destination — genuine place names, addresses,
/// coordinates, and distances, no mocking needed for that part. Only the
/// price tier/rating (which Apple's free search doesn't provide) comes
/// from `HotelEstimating`.
protocol HotelSearching {
    func searchHotels(near destinationQuery: String) async throws -> [Hotel]
}

final class HotelSearchService: HotelSearching {
    private let estimator: HotelEstimating

    init(estimator: HotelEstimating = DefaultHotelEstimator()) {
        self.estimator = estimator
    }

    func searchHotels(near destinationQuery: String) async throws -> [Hotel] {
        // Resolve the destination first so the hotel search can be biased
        // to a tight region around it rather than searching blindly.
        let placeRequest = MKLocalSearch.Request()
        placeRequest.naturalLanguageQuery = destinationQuery
        placeRequest.resultTypes = [.address, .pointOfInterest]
        let placeResponse = try? await MKLocalSearch(request: placeRequest).start()
        guard let destinationItem = placeResponse?.mapItems.first else {
            throw HotelServiceError.placeNotFound(destinationQuery)
        }
        let center = destinationItem.compatCoordinate

        let hotelRequest = MKLocalSearch.Request()
        hotelRequest.naturalLanguageQuery = "hotels"
        hotelRequest.region = MKCoordinateRegion(center: center, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
        hotelRequest.resultTypes = [.pointOfInterest]
        if #available(iOS 13.0, *) {
            hotelRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.hotel])
        }

        let response = try await MKLocalSearch(request: hotelRequest).start()
        guard !response.mapItems.isEmpty else { throw HotelServiceError.noResults }

        let destinationLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        return response.mapItems.map { item in
            let name = item.name ?? "Hotel"
            let address = item.compatFormattedAddress
            let coordinate = item.compatCoordinate
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: destinationLocation)
            let estimate = estimator.estimate(name: name, address: address)

            return Hotel(
                id: "\(name)|\(address)",
                name: name,
                address: address,
                coordinate: coordinate,
                distanceMeters: distance,
                category: estimate.category,
                averagePricePerNight: estimate.price,
                averageRating: estimate.rating
            )
        }
    }
}
