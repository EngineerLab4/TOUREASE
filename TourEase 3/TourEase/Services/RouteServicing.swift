import Foundation
import MapKit

enum RouteServiceError: LocalizedError {
    case placeNotFound(String)
    case noRouteAvailable
    case network

    var errorDescription: String? {
        switch self {
        case .placeNotFound(let name): return "Couldn't find a location matching \"\(name)\"."
        case .noRouteAvailable: return "No route could be calculated between these two points."
        case .network: return "Network error while calculating the route."
        }
    }
}

/// Abstraction over place search + routing so `RoutePlannerViewModel` never
/// touches MapKit types directly — same pattern as `AuthServicing` in the
/// auth module. Unlike auth, this has exactly one real implementation:
/// MapKit's directions/search APIs are free, on-device, and don't need a
/// mock — Apple allows this one to be genuinely live.
protocol RouteServicing {
    func resolvePlace(named query: String) async throws -> MKMapItem
    func calculateRoute(from source: MKMapItem, to destination: MKMapItem,
                         transportType: MKDirectionsTransportType) async throws -> RouteResult
}

final class MapKitRouteService: RouteServicing {

    func resolvePlace(named query: String) async throws -> MKMapItem {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            guard let first = response.mapItems.first else {
                throw RouteServiceError.placeNotFound(query)
            }
            return first
        } catch let error as RouteServiceError {
            throw error
        } catch {
            throw RouteServiceError.network
        }
    }

    func calculateRoute(from source: MKMapItem, to destination: MKMapItem,
                         transportType: MKDirectionsTransportType) async throws -> RouteResult {
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = transportType

        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            guard let route = response.routes.first else {
                throw RouteServiceError.noRouteAvailable
            }
            return RouteResult(
                sourceName: source.name ?? "Source",
                destinationName: destination.name ?? "Destination",
                sourceCoordinate: source.compatCoordinate,
                destinationCoordinate: destination.compatCoordinate,
                distanceMeters: route.distance,
                expectedTravelTime: route.expectedTravelTime,
                polyline: route.polyline,
                transportType: transportType
            )
        } catch let error as RouteServiceError {
            throw error
        } catch {
            throw RouteServiceError.noRouteAvailable
        }
    }
}
